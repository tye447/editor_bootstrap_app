class Sass

  def self.parse(str)
    Ast.new(`parse(#{str})`)
  end

  def self.compile(str)
    `Sass.compile(#{str}, #{lambda{|result| yield(::Hash.new(result)) }.to_n})`
  end
  class Ast
    extend Native::Helpers # see https://github.com/opal/opal/blob/master/stdlib/native.rb
    native_accessor :type
    native_accessor :value, Ast::Array # TODO array of Sass::Ast
    native_accessor :start
    native_accessor :next

    def initialize(ast)
      @native = ast
    end

    def stringify
      `stringify(#{@native});`
    end

    def find(query)

    end


    def find_declaration_variables
      @json = []
      `
      $ = createQueryWrapper(#{@native});
      declarations =  $().children('declaration');
      for(i = 0; i<declarations.length(); i++){
        declaration = declarations.eq(i);

        // get variable name and value
        variable_name = stringify(declaration.children('property').get(0));
        variable_value = stringify(declaration.children('value').get(0)).replace(' !default','').replace(/(^\s*)|(\s*$)/g,"");

        // variables type 'color'
        if(variable_value.indexOf('#')==0){
          variable_type = 'color';
          variable_unit = '';
          if(variable_value.indexOf('#')==0 && variable_value.length == 4){
            tmp = variable_value[0]+variable_value[1]+variable_value[1];
            tmp = tmp+variable_value[2]+variable_value[2];
            tmp = tmp+variable_value[3]+variable_value[3];
            variable_value = tmp;
          }
        }

        // variables type 'variable'
        else if(variable_value.indexOf('$')==0){
          variable_type = 'variable';
          variable_unit = '';
        }

        // variables type 'number'
        else if(!!variable_value.match(/\d/g)){
          // variables with or without unit
          parsed = parseUnit(variable_value);
          if(parsed[1] === 'px' || parsed[1] === 'em' || parsed[1] === 'rem' || parsed[1] === '%' || parsed[1] === ''){
            variable_type = "number";
            variable_value = parsed[0];
            variable_unit = parsed[1];
          }
          else{
            variable_type = "string";
            variable_unit = '';
          }
        }

        // variables type 'string'
        else{
          variable_type = 'string';
          variable_unit = '';
        }

        // add variable to the variable array
        #{@json.push({
          "id"=>`i`,
          "name"=>`variable_name`,
          "type"=>`variable_type`,
          "value"=>`variable_value`,
          "unit"=>`variable_unit`
        })}`

      `}
      `
      return @json
    end

    def replace(variable, options = {})
      `$ = createQueryWrapper(#{@native});
      declarations = $().children('declaration');
      variable_name = #{variable['name']};
      new_value = #{variable['value']};
      new_unit = #{variable['unit']};
      option_change = #{options[:change].to_s};

      // find declaration of the variable changed
      target = declarations.filter((n)=>stringify($(n).children('property').get(0)) === variable_name);

      // remove extra space before the value of the variable
      target.children('value').children().first().replace((n)=>{
        return {type: 'space', value: ' '}
      });

      // delete '!default'
      if(target.children('value').value().includes('!default')){
        target.children('value').find('operator').last().remove();
        target.children('value').find('identifier').last().remove();
        target.children('value').find('space').last().remove();
      }

      if(option_change == 'value'){
        // replace the value
        new_value_ast = parse(new_value.toString())
        target.children('value').first().children().eq(1).replace((n)=>{
          return {type: new_value_ast.value[0].type, value: new_value_ast.value[0].value}
        });
      }

      if(option_change == 'unit'){
        // replace the unit
        children_value = target.children('value').first().children();
        node_value = children_value.eq(1);
        if(children_value.length() > 2){
          node_unit = children_value.eq(2);
        }

        if(new_unit !== ''){
          node_new_unit = parse(new_unit).value[0];
          if(children_value.length() > 2){
            node_unit.replace((n)=>{
              return {type: node_new_unit.type, value: new_unit}
            });
          }
          else if(children_value.length() == 2){
            node_value.after(node_new_unit);
          }
        }
        else{
          node_unit.remove();
        }
      }

      #{@native} = $().get(0);
      `
    end

    def inspect
      %Q[#<Sass::Ast type="#{type}" value=#{value.inspect}>]
    end
  end
end