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


        if(variable_value.indexOf('rgb')==0 || variable_value.indexOf('#')==0){
          variable_type = 'color';
          variable_unit = '';
          if(variable_value.indexOf('#')==0 && variable_value.length == 4){
            tmp = variable_value[0]+variable_value[1]+variable_value[1];
            tmp = tmp+variable_value[2]+variable_value[2];
            tmp = tmp+variable_value[3]+variable_value[3];
            variable_value = tmp;
          }



        }
        else if(variable_value.indexOf('$')==0){
          variable_type = 'variable';
          variable_unit = '';
        }
        else if(types.includes('number')){
          parsed = parseUnit(variable_value);
          if(parsed.length <= 2){
            variable_type = "number";
            variable_value = parsed[0];
            if(parsed[1] === 'px' || parsed[1] === 'em' || parsed[1] === 'rem' || parsed[1] === '%'){
              variable_unit = parsed[1];
            }
            else{
              variable_unit = '';
            }
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

      if(values.first().value().includes(' ')){
        values.find('space').first().replace((n)=>{
          return {type: 'space', value: ' '}
        });
      }

      if(target.children('value').value().includes('!default')){
        values.find('operator').last().remove();
        values.find('identifier').last().remove();
        values.find('space').last().remove();
      }

      variable_value = stringify(target.children('value').get(0)).replace(' !default','').substring(1);

      console.log(variable_value);
      if(variable_value.indexOf('rgb')==0 || variable_value.indexOf('#')==0){
        old_type = 'color_hex';
      }
      else if(variable_value.indexOf('$')==0){
        old_type = 'variable';
        variable_value = variable_value.substring(1);
      }

      else if(!isNaN(Number(variable_value))){
        old_type = 'number';
      }
      else{
        old_type = 'string';
      }

      if(new_value.indexOf('rgb')==0 || new_value.indexOf('#')==0){
        new_value_type = 'color_hex';
        new_value = new_value.substring(1);
      }
      else if(new_value.indexOf('$')==0){
        new_value_type = 'variable';
        new_value = new_value.substring(1);
      }

      else if(!isNaN(Number(new_value))){
        new_value_type = 'number';
      }
      else{
        new_value_type = 'string';
      }

      if(new_value_type !== 'string' && old_type !=='string'){

        values.find(old_type).replace((n)=>{
          return {type: new_value_type, value: new_value}
        });
      }
      else{
        console.log(target.children('value').value())
      }
      /*if(types.includes('function')){
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
        });*/
      #{@native} = $().get(0);
      `
    end

    def inspect
      %Q[#<Sass::Ast type="#{type}" value=#{value.inspect}>]
    end
  end
end