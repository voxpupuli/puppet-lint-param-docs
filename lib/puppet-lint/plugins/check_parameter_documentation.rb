PuppetLint.new_check(:parameter_documentation) do
  def check
    class_indexes.concat(defined_type_indexes).each do |idx|
      next if idx[:param_tokens].nil?

      doc_params = {}
      doc_params_duplicates = Hash.new { |hash, key| hash[key] = [doc_params[key]] }
      is_private = false
      tokens[0..idx[:start]].reverse_each do |dtok|
        next if [:CLASS, :DEFINE, :NEWLINE, :WHITESPACE, :INDENT].include?(dtok.type)
        if dtok.type == :COMMENT
          if dtok.value =~ /\A\s*\[\*([a-zA-Z0-9_]+)\*\]/ or
             dtok.value =~ /\A\s*\$([a-zA-Z0-9_]+):: +/ or
             dtok.value =~ /\A\s*@param (?:\[.+\] )?([a-zA-Z0-9_]+)(?: +|$)/
            if doc_params.include? $1
              doc_params_duplicates[$1] << dtok
            else
              doc_params[$1] = dtok
            end
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
            nesting = 0
            # skip to the next parameter to avoid finding default values of variables
            while true
              ptok = e.next
              case ptok.type
              when :LPAREN
                nesting += 1
              when :RPAREN
                nesting -= 1
              when :COMMA
                break unless nesting > 0
              end
            end
          end
        end
      rescue StopIteration; end

      # warn about duplicates
      doc_params_duplicates.each do |parameter, tokens|
        tokens.each do |token|
           notify :warning, {
             :message => "Duplicate parameter documentation for #{parameter}",
             :line    => token.line,
             :column  => token.column + token.value.match(/\A\s*(@param\s*)?/)[0].length + 1 # `+ 1` is to account for length of the `#` COMMENT token.
           }
        end
      end

      params.each do |p|
        next if doc_params.has_key? p.value
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
