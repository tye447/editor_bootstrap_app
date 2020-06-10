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
        declaration = declarations.eq(i);
        property = declaration.children('property');
        property_value = '$'+property.value();
        value = declaration.children('value').children();
        value_type = value.map((n)=>n.node.type);
        value_value = value.value();
        target_value_unit = '';
        if(value_type.includes('color_hex')){
          target = value.find('color_hex');
          target_value = '#'+target.value();
          target_type = 'color';
        }
        else if(value_type.includes('number')){
          target = value.find('number');
          if(target.next().map((n)=>n.node.type).includes('identifier')){
            target_value = target.value();
            target_type = 'number';
            target_value_unit = target.next().value();
          }
          else{
            target_value = target.value();
            target_type = 'number';
          }
        }
        else if(value_type.includes('variable')){
          target = value.find('variable');
          target_value = '$'+target.value();
          target_type = 'variable';
        }
        else{
          target = value.first().nextAll();
          target_value = target.value();
          target_value = target_value.replace(' !default','');
          target_type = 'string';
        }


        #{@json.push({
          "id"=>`i`,
          "name"=>`property_value`,
          "type"=>`target_type`,
          "value"=>`target_value`,
          "unit"=>`target_value_unit`
        })}`

      `}
      `
      return @json
    end

    def replace(variable_name,new_type,new_value)
      `$ = createQueryWrapper(#{@native});
      declarations = $().children('declaration');
      new_type = #{new_type};
      variable_name = #{variable_name};
      new_value = #{new_value};
      variable_name = variable_name.substring(1);
      target = declarations.filter((n)=>$(n).children('property').value() === variable_name);
      values= target.children('value').children();
      if(new_type=='color'){
        new_type='color_hex';
        new_value = new_value.substring(1);
      }
      if(new_type=='variable'){
        new_value = new_value.substring(1);
      }
      values.find(new_type).replace((n)=>{
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