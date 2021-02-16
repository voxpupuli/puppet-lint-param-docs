PuppetLint.new_check(:parameter_documentation) do
  def check
    check_private = PuppetLint.configuration.docs_check_private_params || false

    class_indexes.concat(defined_type_indexes).each do |idx|
      doc_params = {}
      doc_params_duplicates = Hash.new { |hash, key| hash[key] = [doc_params[key]] }
      is_private = false
      tokens[0..idx[:start]].reverse_each do |dtok|
        next if [:CLASS, :DEFINE, :NEWLINE, :WHITESPACE, :INDENT].include?(dtok.type)
        if dtok.type == :COMMENT
          if dtok.value =~ /\A\s*\[\*([a-zA-Z0-9_]+)\*\]/ or
             dtok.value =~ /\A\s*\$([a-zA-Z0-9_]+):: +/ or
             dtok.value =~ /\A\s*@param (?:\[.+\] )?([a-zA-Z0-9_]+)(?: +|$)/
            parameter = $1
            parameter = 'name/title' if idx[:type] == :DEFINE && ['name','title'].include?(parameter)
            if doc_params.include? parameter
              doc_params_duplicates[parameter] << dtok
            else
              doc_params[parameter] = dtok
            end
          end

          is_private = true if dtok.value =~ /\A\s*@api +private\s*$/
        else
          break
        end
      end

      params = extract_params(idx)

      # warn about duplicates
      doc_params_duplicates.each do |parameter, tokens|
        tokens.each do |token|
           notify :warning, {
             :message => "Duplicate #{type_str(idx)} parameter documentation for #{idx[:name_token].value}::#{parameter}",
             :line    => token.line,
             :column  => token.column + token.value.match(/\A\s*(@param\s*)?/)[0].length + 1 # `+ 1` is to account for length of the `#` COMMENT token.
           }
        end
      end

      # warn about documentation for parameters that don't exist
      doc_params.each do |parameter, token|
        next if parameter == 'name/title' && idx[:type] == :DEFINE
        next if params.find { |p| p.value == parameter }

        notify :warning, {
          :message => "No matching #{type_str(idx)} parameter for documentation of #{idx[:name_token].value}::#{parameter}",
          :line    => token.line,
          :column  => token.column + token.value.match(/\A\s*(@param\s*)?/)[0].length + 1
        }
      end

      unless is_private and not check_private
        params.each do |p|
          next if doc_params.has_key? p.value
          notify :warning, {
            :message => "missing documentation for #{type_str(idx)} parameter #{idx[:name_token].value}::#{p.value}",
            :line    => p.line,
            :column  => p.column,
          }
        end
      end
    end
  end

  private

  def type_str(idx)
    idx[:type] == :CLASS ? "class" : "defined type"
  end

  def extract_params(idx)
    params = []
    return params if idx[:param_tokens].nil?

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

    params
  end
end
