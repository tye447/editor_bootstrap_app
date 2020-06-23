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
      @json = []
      `
      $ = createQueryWrapper(#{@native});
      declarations =  $().children('declaration');
      result = declarations.find(query);
      length = result.length();
      for(i = 0;i<length;i++){
      type = result.eq(i).map((n)=>n.node.type).toString();
      value = result.eq(i).value();
      if(type=='color_hex'){
        type = 'color';
        value ='#'+value;
      }
      if(type=='variable'){
        value ='$'+value;
      }
      #{@json.push({"id"=>`i`,"type"=>`type`,"value"=>`value`})}
      }
      `
      return @json
    end


    def find_declaration_variables
      @json = []
      `
      $ = createQueryWrapper(#{@native});
      declarations =  $().children('declaration');
      length = declarations.length();
      for(i = 0;i<length;i++){
        variable_unit = '';
        declaration = declarations.eq(i);
        variable_name = stringify(declaration.children('property').get(0));
        declaration.children('value').children().first().remove();
        variable_value = stringify(declaration.children('value').get(0)).replace(' !default','');
        types = declaration.children('value').children().map((n)=>n.node.type);

        if(declaration.children('value').children().length()>=8){
          variable_type = 'string';
          variable_unit = '';
        }
        else if(types.includes('function')){
          variable_type = 'string';
          variable_unit = '';
        }
        else if(types.includes('string-double')){
          variable_type = 'string';
          variable_unit = '';
        }
        else if(types.includes('color_hex')){
          if(variable_value.length == 4){
            test = variable_value[0];
            for(var j=1;j<=3;j++){
              test += variable_value[j];
              test += variable_value[j];
            }
            variable_value = test;
          }
          variable_type = "color";
        }
        else if(types.includes('variable')){
          variable_type = 'variable';
          variable_unit = '';
        }
        else if(types.includes('number')){
          variable_type = "number";
          test = declaration.find('number');
          next = declaration.find('number').next();
          variable_value = test.value();
          if(next.value()==="rem"||next.value()==="em"||next.value()==="px"||next.value()==="%"){
            variable_unit = next.value();
          }
          else if(next.value()==="s"){
            variable_type = "string";
            variable_value = stringify(declaration.children('value').get(0)).replace(' !default','');
            variable_unit = "";
          }
          else{
            variable_unit = "";
          }
        }
        else{
          variable_type = 'string';
          variable_unit = '';
        }
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

    def replace(variable_name,type,new_value)
      `$ = createQueryWrapper(#{@native});
      declarations = $().children('declaration');
      type = #{type};
      variable_name = #{variable_name};
      new_value = #{new_value};
      variable_name = variable_name.substring(1);
      target = declarations.filter((n)=>$(n).children('property').value() === variable_name);
      values= target.children('value').children();
      types = values.map((n)=>n.node.type);
      if(types.includes('function')){
      old_type = 'function';
      }
      else if(types.includes('string-double')){
      old_type = 'string-double';
      }
      else if(types.includes('color_hex')){
      old_type = 'color_hex';
      }
      else if(types.includes('variable')){
      old_type = 'variable';
      }
      else{
      old_type = 'string';
      }
      if(type=='color'){
      type = 'color_hex';
      }
      if((type=='color_hex'||type=='variable')){
      new_value = new_value.substring(1);
      }
      values.find(old_type).replace((n)=>{
      return {type:type,value: new_value}
      });
      #{@native} = $().get(0);
      `
    end

    def inspect
      %Q[#<Sass::Ast type="#{type}" value=#{value.inspect}>]
    end
  end
end