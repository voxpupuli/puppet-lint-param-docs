PuppetLint.new_check(:parameter_documentation) do
  def check
    allowed_styles = PuppetLint.configuration.docs_allowed_styles || %w[doc kafo strings]
    allowed_styles = [allowed_styles].flatten

    class_indexes.concat(defined_type_indexes).each do |idx|
      doc_params = {}
      doc_params_styles = {}
      doc_params_duplicates = Hash.new { |hash, key| hash[key] = [doc_params[key]] }
      is_private = false
      tokens[0..idx[:start]].reverse_each do |dtok|
        next if %i[CLASS DEFINE NEWLINE WHITESPACE INDENT].include?(dtok.type)

        next unless dtok.type == :COMMENT

        if /\A\s*@api +private\s*$/.match?(dtok.value)
          is_private = true
          next
        end

        style = detect_style(dtok)
        # not a doc parameter if style has not been detected
        next if style[0].nil?

        parameter = style[2]
        parameter = 'name/title' if idx[:type] == :DEFINE && %w[name title].include?(parameter)
        if doc_params.include? parameter
          doc_params_duplicates[parameter] << dtok
        else
          doc_params[parameter] = dtok
          doc_params_styles[parameter] = style[0]
        end
      end

      params = extract_params(idx)

      # warn about duplicates
      doc_params_duplicates.each do |parameter, tokens|
        tokens.each do |token|
          notify :warning, {
            message: "Duplicate #{type_str(idx)} parameter documentation for #{idx[:name_token].value}::#{parameter}",
            line: token.line,
            column: token.column + token.value.match(/\A\s*(@param\s*)?/)[0].length + 1, # `+ 1` is to account for length of the `#` COMMENT token.
          }
        end
      end

      # warn about documentation for parameters that don't exist
      doc_params.each do |parameter, token|
        next if parameter == 'name/title' && idx[:type] == :DEFINE
        next if params.find { |p| p.value == parameter }

        notify :warning, {
          message: "No matching #{type_str(idx)} parameter for documentation of #{idx[:name_token].value}::#{parameter}",
          line: token.line,
          column: token.column + token.value.match(/\A\s*(@param\s*)?/)[0].length + 1,
        }
      end

      next if is_private

      params.each do |p|
        if doc_params.has_key? p.value
          style = doc_params_styles[p.value] || 'unknown'
          unless allowed_styles.include?(style)
            notify :warning, {
              message: "invalid documentation style for #{type_str(idx)} parameter #{idx[:name_token].value}::#{p.value} (#{doc_params_styles[p.value]})",
              line: p.line,
              column: p.column,
            }
          end
        else
          notify :warning, {
            message: "missing documentation for #{type_str(idx)} parameter #{idx[:name_token].value}::#{p.value}",
            line: p.line,
            column: p.column,
          }
        end
      end
    end
  end

  private

  def type_str(idx)
    idx[:type] == :CLASS ? 'class' : 'defined type'
  end

  def extract_params(idx)
    params = []
    return params if idx[:param_tokens].nil?

    e = idx[:param_tokens].each
    begin
      while (ptok = e.next)
        next unless ptok.type == :VARIABLE

        params << ptok
        nesting = 0
        # skip to the next parameter to avoid finding default values of variables
        while true
          ptok = e.next
          case ptok.type
          when :LPAREN, :LBRACK, :LBRACE
            nesting += 1
          when :RPAREN, :RBRACK, :RBRACE
            nesting -= 1
          when :COMMA
            break unless nesting > 0
          end
        end
      end
    rescue StopIteration; end

    params
  end

  # returns an array [<detected_style>, <complete match>, <param name>, <same-line-docs>]
  # [nil, nil] if this is not a parameter.
  def detect_style(dtok)
    style = nil
    case dtok.value
    when /\A\s*\[\*([a-zA-Z0-9_]+)\*\]\s*(.*)\z/
      style = 'doc'
    when /\A\s*\$([a-zA-Z0-9_]+):: +(.*)\z/
      style = 'kafo'
    when /\A\s*@param (?:\[.+\] )?([a-zA-Z0-9_]+)(?: +|$)(.*)\z/
      style = 'strings'
    end
    [style, * $~]
  end
end
