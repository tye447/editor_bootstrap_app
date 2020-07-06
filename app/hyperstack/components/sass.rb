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

    def duplicate # duplicate
      Ast.new(`Object.assign({},#{@native})`)
      # Ast.new(`JSON.parse(JSON.stringify(#{@native}))`)
    end

    def find_declaration_variables
      # find all variables of declarations
      `
      array = [];
      query = createQueryWrapper(#{@native});
      declarations =  query().children('declaration');
      for(i = 0; i<declarations.length(); i++){
        declaration = declarations.eq(i);

        // get variable name and value
        var_name = stringify(declaration.children('property').get(0));
        var_value = stringify(declaration.children('value').get(0)).replace(' !default','').replace(/(^\s*)|(\s*$)/g,"");
        var_parsed = parse(var_value).value;

        // variables type 'string'
        if(var_parsed.length > 2 || var_parsed.length == 0){
          var_type = 'string';
          var_unit = '';
        }
        else{
          // variables type 'color'
          if(var_parsed[0].type == 'color_hex'){
            var_type = 'color';
            var_unit = '';
            if(var_value.length == 4){
              tmp = var_value[0]+var_value[1]+var_value[1];
              tmp = tmp+var_value[2]+var_value[2];
              tmp = tmp+var_value[3]+var_value[3];
              var_value = tmp;
            }
          }

          // variables type 'variable'
          else if(var_parsed[0].type == 'variable'){
            var_type = 'variable';
            var_unit = '';
          }

          // variables type 'number'
          else if(var_parsed[0].type == 'number'){
            // variables with or without unit
            var_type = "number";
            var_value = var_parsed[0].value
            if(var_parsed.length == 1){
              var_unit = '';
            }
            else{
              var_unit = var_parsed[1].value;
              if(var_unit != 'px' && var_unit != 'em' && var_unit != 'rem' && var_unit != '%'){
                var_unit = '';
                var_type = 'string';
              }
            }
          }

          else{
            var_unit = '';
            var_type = 'string';
          }
        }

        // add variable to the variable array
        item = {'id':i,'name':var_name,'type':var_type,'value':var_value,'unit':var_unit};
        array.push(item);
      }
      `
      @array = JSON.parse(`JSON.stringify(array)`)
      return @array
    end

    def add(variable,index)
      `query = createQueryWrapper(#{@native});
      new_value_ast = parse(#{variable['name']} + ": " + #{variable['value']} + #{variable['unit']}+";\n");
      query().children('declaration').eq(#{index}).before(new_value_ast.value[1]);
      query().children('declaration').eq(#{index}).prev().before(new_value_ast.value[0]);
      #{@native} = query().get(0);
      `
    end

    def replace(variable)
      `query = createQueryWrapper(#{@native});

      // find declaration of the variable changed
      target = query().children('declaration').filter((n)=>stringify(query(n).children('property').get(0)) === #{variable['name']});

      // replace the value
      if(target.length() !== 0){
        new_value_ast = parse(' '+#{variable['value']}+#{variable['unit']});
        target.children('value').first().replace((n)=>{
          return {type: 'value', value: new_value_ast.value}
        });
      }
      #{@native} = query().get(0);
      `
    end

    def find_changed_value
      `
      query = createQueryWrapper(#{@native});
      declarations =  query().children('declaration');
      targets = declarations.filter((n)=>stringify(query(n).children('value').get(0)).indexOf('default') == -1);
      string = "";
      for(i = 0; i<targets.length(); i++){
        string += stringify(targets.eq(i).get(0))+"\n";
      }
      `
      return `string`
    end

    def inspect
      %Q[#<Sass::Ast type="#{type}" value=#{value.inspect}>]
    end
  end
end