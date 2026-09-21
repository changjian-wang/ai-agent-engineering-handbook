require "nokogiri"
require "pathname"
require "uri"
require "yaml"

root = Pathname.new(ARGV.fetch(0, "_site")).expand_path
config = YAML.safe_load_file("_config.yml")
baseurl = config.fetch("baseurl", "").delete_suffix("/")
origin = config.fetch("url")
site_host = URI(origin).host
failures = []
references = 0
required_pages = %w[index.html roadmap/index.html coverage/index.html chapters/ai-foundations/index.html chapters/math-and-programming/index.html]

Dir.glob(".github/workflows/*.yml").each do |workflow_path|
  workflow = YAML.safe_load_file(workflow_path)
  next unless File.basename(workflow_path).match?(/\A[0-4]-/)

  triggers = workflow.fetch("on", workflow[true])
  first_job = workflow.fetch("jobs").values.first
  unless triggers.keys == ["workflow_dispatch"] && first_job["if"] == '${{ false }}'
    failures << "Legacy exercise must remain inactive: #{workflow_path}"
  end
end

required_pages.each do |relative|
  failures << "Missing required page: #{relative}" unless root.join(relative).file?
end

documents = root.glob("**/*.html").to_h do |path|
  [path, Nokogiri::HTML5(path.read)]
end

documents.each do |path, document|
  relative = path.relative_path_from(root).to_s
  route = relative.delete_suffix("index.html")
  page_url = URI("#{origin}#{baseurl}/#{route}")
  failures << "#{relative}: expected exactly one main heading" unless document.css("main h1").length == 1
  failures << "#{relative}: missing Chinese language metadata" unless document.at_css("html")&.[]("lang") == "zh-CN"
  failures << "#{relative}: missing page title" if document.at_css("title")&.text.to_s.strip.empty?
  failures << "#{relative}: unresolved Liquid expression" if document.text.include?("{{") || document.text.include?("{%")

  identifiers = document.css("[id]").map { |element| element["id"] }
  failures << "#{relative}: duplicate element IDs" unless identifiers.uniq == identifiers

  document.css("img").each do |image|
    failures << "#{relative}: image without alternative text" if image["alt"].to_s.strip.empty?
  end

  document.css("a[href], link[href], script[src], img[src]").each do |element|
    value = element["href"] || element["src"]
    next if value.start_with?("mailto:", "tel:")

    begin
      target_url = URI.join(page_url.to_s, value)
      next unless target_url.host == site_host

      references += 1
      target_path = URI::DEFAULT_PARSER.unescape(target_url.path)
      unless target_path == baseurl || target_path.start_with?("#{baseurl}/")
        failures << "#{relative}: URL escapes project base path: #{value}"
        next
      end

      local_path = target_path.delete_prefix(baseurl).delete_prefix("/")
      target_file = root.join(local_path).cleanpath
      target_file = target_file.join("index.html") if target_file.directory?
      unless target_file.to_s.start_with?("#{root}/") && target_file.file?
        failures << "#{relative}: missing local target: #{value}"
        next
      end

      if target_url.fragment && !target_url.fragment.empty?
        fragment = URI::DEFAULT_PARSER.unescape(target_url.fragment)
        target_document = documents[target_file]
        unless target_document && target_document.css("[id]").any? { |element_with_id| element_with_id["id"] == fragment }
          failures << "#{relative}: missing anchor: #{value}"
        end
      end
    rescue URI::InvalidURIError => error
      failures << "#{relative}: invalid URL #{value}: #{error.message}"
    end
  end
end

%w[Gemfile Gemfile.lock README.md scripts examples .venv .vscode vendor .git .github].each do |private_path|
  failures << "Build-only file published: #{private_path}" if root.join(private_path).exist?
end

coverage = documents[root.join("coverage/index.html")]
if coverage
  entries = coverage.css("td").map(&:text)
  expected = (1..34).map { |number| format("WX%02d", number) }
  actual = entries.grep(/\AWX\d+\z/)
  failures << "Source coverage entries are missing or duplicated" unless actual.sort == expected
end

math_chapter = documents[root.join("chapters/math-and-programming/index.html")]
if math_chapter
  sections = %w[scope python tensors linear-algebra calculus probability information engineering lab exercises interview next references]
  rendered_sections = math_chapter.css("main h2[id]").map { |heading| heading["id"] }
  failures << "M01 sections are missing or rendered as code" unless rendered_sections == sections
  failures << "M01 Python examples did not render as code" unless math_chapter.css("div.language-python pre code").length == 3
end

if failures.any?
  warn failures.join("\n")
  exit 1
end

puts "PASS: #{documents.length} HTML pages, #{references} internal references, valid anchors and assets."