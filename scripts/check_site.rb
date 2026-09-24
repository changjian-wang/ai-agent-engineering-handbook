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
required_pages = %w[index.html roadmap/index.html chapters/ai00-1/index.html]
retired_pages = %w[coverage/index.html chapters/ai-foundations/index.html chapters/math-and-programming/index.html chapters/tokens-and-embeddings/index.html chapters/pretraining-and-sft/index.html chapters/agent-tool-loop/index.html]

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

retired_pages.each do |relative|
  failures << "Retired content still published: #{relative}" if root.join(relative).exist?
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

roadmap = documents[root.join("roadmap/index.html")]
if roadmap
  sections = %w[start stages ai-track agent-track interview sources gaps writing-order]
  rendered_sections = roadmap.css("main h2[id]").map { |heading| heading["id"] }
  failures << "Curriculum sections are missing or out of order" unless rendered_sections == sections
  modules = (0..14).map { |number| format("ai%02d", number) } + (0..9).map { |number| format("ag%02d", number) }
  module_headings = roadmap.css("main h3[id]")
  failures << "AI and Agent curriculum modules are missing or duplicated" unless module_headings.map { |heading| heading["id"] } == modules
  fields = %w[先修 核心 进阶 主读 验收]
  module_headings.each do |heading|
    list = heading.next_element
    labels = list&.name == "ul" ? list.element_children.map { |item| item.text.strip[/\A[^：]+/] } : []
    failures << "#{heading['id']}: module fields must be #{fields.join('/')}" unless labels == fields
  end
end

article = documents[root.join("chapters/ai00-1/index.html")]
if article
  sections = %w[what-is-ai what-is-ml what-is-dl comparison pitfalls self-check sources]
  failures << "AI00.1 sections are missing or out of order" unless article.css("main h2[id]").map { |heading| heading["id"] } == sections
  answers = article.css("main details[id^='answer-']")
  unless answers.length == 3 && answers.all? { |answer| answer.at_css("summary") && !answer.key?("open") }
    failures << "AI00.1 needs three collapsed self-check answers"
  end
end

if failures.any?
  warn failures.join("\n")
  exit 1
end

puts "PASS: #{documents.length} HTML pages, #{references} internal references, valid anchors and assets."