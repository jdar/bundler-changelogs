class StandardFormatRepoChangelog
  attr_accessor :content
  def initialize(previous_spec,content)
    @content = content
  end
  def since(to_str_able)
    post_process(try_split(to_str_able.to_s).first)
  end

  #dumb strategy.
  def try_split(dumb_tokenizer_token)
    first,*last = content.split(dumb_tokenizer_token)
    [first,last.join(dumb_tokenizer_token)]
  end

  #dumb cleaning. Remove markdown?
  def post_process(orig_str)
    str = orig_str.dup
    str.gsub!(/^\s*changelog[^\w]+/)
    str
  end
end