PuppetLint.new_check(:parameter_documentation) do
  def check
    class_indexes.concat(defined_type_indexes).each do |idx|
      next if idx[:param_tokens].nil?

      doc_params = []
      is_private = false
      tokens[0..idx[:start]].reverse_each do |dtok|
        next if [:CLASS, :DEFINE, :NEWLINE, :WHITESPACE, :INDENT].include?(dtok.type)
        if [:COMMENT, :MLCOMMENT, :SLASH_COMMENT].include?(dtok.type)
          if dtok.value =~ /\A\s*\[\*([a-zA-Z0-9_]+)\*\]/ or
             dtok.value =~ /\A\s*\$([a-zA-Z0-9_]+):: +/ or
             dtok.value =~ /\A\s*@param (?:\[.+\] )?([a-zA-Z0-9_]+)(?: +|$)/
            doc_params << $1
          end

          is_private = true if dtok.value =~ /\A\s*@api +private\s*$/
        else
          break
        end
      end

      next if is_private

      params = []
      e = idx[:param_tokens].each
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
        idx_type = idx[:type] == :CLASS ? "class" : "defined type"
        notify :warning, {
          :message => "missing documentation for #{idx_type} parameter #{idx[:name_token].value}::#{p.value}",
          :line    => p.line,
          :column  => p.column,
        }
      end
    end
  end
end
