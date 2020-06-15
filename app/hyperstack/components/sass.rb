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
        if(types.includes('color_hex')){
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
        else if(types.includes('number')){
          variable_type = "number";
          var regexStr = variable_value.match(/[a-z]+|[^a-z]+/gi);
          variable_value = regexStr[0];
          if(regexStr.length!==1){
            variable_unit = regexStr[1];
          }
        }
        else if(types.includes('variable')){
          variable_type = 'variable';
          variable_unit = '';
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

    def replace(variable_name,old_type,new_type,new_value)
      `$ = createQueryWrapper(#{@native});
      declarations = $().children('declaration');
      new_type = #{new_type};
      old_type = #{old_type};
      variable_name = #{variable_name};
      new_value = #{new_value};
      variable_name = variable_name.substring(1);
      target = declarations.filter((n)=>$(n).children('property').value() === variable_name);
      values= target.children('value').children();
      if(old_type=='color'){
        old_type = 'color_hex';
      }
      if(new_type=='color'){
        new_type = 'color_hex';
      }
      if(old_type=='string'){
        old_type = 'string-double';
      }
      if(new_type=='string'){
        new_type = 'string-double';
      }
      if(new_type=='color_hex'||new_type=='variable'){
        new_value = new_value.substring(1);
      }
      
      if(old_type !== 'variable' || new_type !== 'color_hex'){
        if(values.find('id').length()!==0){
          old_type='id';
        }
      }
      values.find(old_type).replace((n)=>{
        return {type:new_type,value: new_value}
      });
      #{@native} = $().get(0);
      `
    end

    def inspect
      %Q[#<Sass::Ast type="#{type}" value=#{value.inspect}>]      
    end
  end
    
end