const article = document.querySelector('.prose');

if (article) {
  if (typeof window.renderMathInElement === 'function') {
    window.renderMathInElement(article, {
      delimiters: [
        { left: '$$', right: '$$', display: true },
        { left: '\\[', right: '\\]', display: true },
        { left: '\\(', right: '\\)', display: false },
        { left: '$', right: '$', display: false },
      ],
      throwOnError: false,
      trust: false,
    });
  }

  article.querySelectorAll('table').forEach((table, index) => {
    const wrapper = document.createElement('div');
    wrapper.className = 'table-scroll';
    wrapper.tabIndex = 0;
    wrapper.setAttribute('role', 'region');
    wrapper.setAttribute('aria-label', `数据表 ${index + 1}`);
    table.before(wrapper);
    wrapper.append(table);
  });

  const navigation = document.querySelector('#page-navigation');
  const sections = document.querySelector('#page-sections');
  const headings = article.querySelectorAll('h2[id]');

  if (navigation && sections && headings.length) {
    headings.forEach((heading) => {
      const item = document.createElement('li');
      const link = document.createElement('a');
      link.href = `#${encodeURIComponent(heading.id)}`;
      link.textContent = heading.textContent;
      item.append(link);
      sections.append(item);
    });
    const desktop = window.matchMedia('(min-width: 901px)');
    navigation.open = desktop.matches;
    navigation.hidden = false;
    desktop.addEventListener('change', (event) => {
      navigation.open = event.matches;
    });
  }
}