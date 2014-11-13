PuppetLint.new_check(:parameter_documentation) do
  def check
    class_indexes.each do |klass|
      next if klass[:param_tokens].nil?

      doc_params = []
      tokens[0..klass[:start]].reverse_each do |dtok|
        next if [:CLASS, :NEWLINE, :WHITESPACE, :INDENT].include?(dtok.type)
        if [:COMMENT, :MLCOMMENT, :SLASH_COMMENT].include?(dtok.type)
          if dtok.value =~ /\A\s*\[\*([a-zA-Z0-9_]+)\*\]/ or
             dtok.value =~ /\A\s*\$([a-zA-Z0-9_]+)::/
            doc_params << $1
          end
        else
          break
        end
      end

      params = []
      e = klass[:param_tokens].each
      begin
        while (ptok = e.next)
          if ptok.type == :VARIABLE
            params << ptok
            # skip to the next parameter to avoid finding default values of variables
            while true
              ptok = e.next
              break if ptok.type == :COMMA
            end
          end
        end
      rescue StopIteration; end

      params.each do |p|
        next if doc_params.include? p.value
        notify :warning, {
          :message => "missing documentation for class parameter #{klass[:name_token].value}::#{p.value}",
          :line    => p.line,
          :column  => p.column,
        }
      end
    end
  end
end
