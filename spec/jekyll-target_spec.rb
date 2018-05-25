# frozen_string_literal: true

RSpec.describe(Jekyll::TargetBlank) do
  Jekyll.logger.log_level = :error

  let(:config_overrides) {{}}
  let(:configs) do
    Jekyll.configuration(config_overrides.merge({
      "skip_config_files" => false,
      "collections" => {"docs" => {"output" => true}},
      "source" => fixtures_dir,
      "destination" => fixtures_dir("_site"),
    }))
  end
  let(:target_blank) { described_class }
  let(:site) { Jekyll::Site.new(configs) }
  let(:posts) { site.posts.docs.sort.reverse }

  # get some fixtures
  let(:post_with_external_markdown_link) { find_by_title(posts, 'Post with external markdown link') }

  let(:post_with_multiple_external_markdown_links) { find_by_title(posts, 'Post with multiple external markdown links') }

  let(:post_with_relative_markdown_link) { find_by_title(posts, 'Post with relative markdown link') }

  let(:post_with_absolute_internal_markdown_link) { find_by_title(posts, 'Post with absolute internal markdown link') }

  let(:post_with_html_anchor_tag) { find_by_title(posts, 'Post with html anchor tag') }

  let(:post_with_plain_text_link) { find_by_title(posts, 'Post with plain text link') }

  let(:document_with_a_processable_link) { find_by_title(site.collections["docs"].docs, 'Document with a processable link') }

  # define common wrappers.
  def para(content)
    "<p>#{content}</p>"
  end

  before(:each) do
    site.reset
    site.read
    (site.pages | posts | site.docs_to_write).each { |p| p.content.strip! }
    site.render
  end

  it 'should add target attribute to external markdown link' do
    expect(post_with_external_markdown_link.output).to start_with(para('Link to <a href="https://google.com" target="_blank">Google</a>.'))
  end

  it 'should add target attribute to multiple external markdown links' do
    expect(post_with_multiple_external_markdown_links.output).to eq('<p>This post contains three links. The first link is to <a href="https://google.com" target="_blank">Google</a>, the second link is, well, to <a href="https://keithmifsud.github.io" target="_blank">my website</a> and since <a href="https://github.com" target="_blank">GitHub</a> is so awesome, why not link to them too?</p>
'
)
  end

  it 'should not add target attribute to relative markdown link' do
    expect(post_with_relative_markdown_link.output).to start_with(para('Link to <a href="/contact">contact page</a>.'))
  end


  it 'should not add target attribute to absolute internal link' do
    expect(post_with_absolute_internal_markdown_link.output).to eq('<p>This is an absolute internal <a href="https://keith-mifsud.me/contact">link</a>.</p>
')
  end

  it 'should correctly handle existing html anchor tag' do
    expect(post_with_html_anchor_tag.output).to eq('<p>This is an <a href="https://google.com" target="_blank">anchor tag</a>.</p>
')
  end

  it 'should not interfere with plain text link' do
    expect(post_with_plain_text_link.output).to eq('<p>This is a plain text link to https://google.com.</p>
')
  end

  it 'should process external links in collections' do
    expect(document_with_a_processable_link.output).to eq('<p>This is a valid <a href="https://google.com" target="_blank">link</a>.</p>
')
  end

  it 'should process external links in pages' do
    expect(site.pages.first.output).to include('<p>This is a valid <a href="https://google.com" target="_blank">link</a>.</p>')
  end




  #
  # layouts should not be touched.
  #
  # non convertible files such as .txt
  #
  # what about code blocks?
  #
  # mix with internal and external
  #


end