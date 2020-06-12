class Preview < HyperComponent
  include Hyperstack::Router::Helpers
  param :css , default: ''
  render(DIV) do
    # STYLE{css}
    # buttons
    # cards
    # forms
    # list
    # navs
    # tables
  end

  after_mount do
    puts "after_mount"
    listen_css
  end

  def listen_css

    `
    window.addEventListener("message",function(e){
        console.log(e.data);
    })

    
    `
  end
  
  def buttons
    DIV(class:'button') do
      H2{'Buttons'}
      BUTTON(class:'btn btn-primary'){"Primary"}
      BUTTON(class:'btn btn-secondary'){"Secondary"}
      BUTTON(class:'btn btn-success'){"Success"}
      BUTTON(class:'btn btn-danger'){"Danger"}
      BUTTON(class:'btn btn-warning'){"Warning"}
      BUTTON(class:'btn btn-info'){"Info"}
    end
  end

  def cards
    H2{'Cards'}
    DIV(class:'card',style:{'width': '18rem'}) do
      DIV(class:'card-body') do
        H5(class:'card-title'){'Card title'}
        P(class:'card-text'){'Card Text'}
      end
    end
  end

  def forms
    DIV(class:'form') do
      H2{'Forms'}
      FORM do
        DIV(class:'form-group') do
          LABEL(htmlFor: :exampleInputEmail1){'Email address'}
          INPUT(type: :email, class:'form-control', id:'exampleInputEmail1', placeholder:'Enter email')
        end
        DIV(class:'form-group') do
          LABEL(htmlFor: :exampleInputPassword1){'Password'}
          INPUT(type: :password, class:'form-control', id:'exampleInputPassword1', placeholder:'Password')
        end
        BUTTON(class:'btn btn-primary'){'Submit'}
      end
    end
  end

  def list
    H2{'List'}
    UL(class:'list-group') do
      LI(class:'list-group-item'){'1'}
      LI(class:'list-group-item'){'2'}
      LI(class:'list-group-item'){'3'}
    end
  end

  def navs
    H2{'Navs'}
    NAV(class:'nav') do
      A(class:'nav-link active'){'Home'}
      A(class:'nav-link'){'Features'}
      A(class:'nav-link'){'Pricing'}
      A(class:'nav-link disabled'){'Disabled'}
    end
  end
  
  def tables
    H2{'Tables'}
    TABLE(class: 'ui celled table') do
      THEAD do
        TR do
          TH{'1'}
          TH{'2'}
          TH{'3'}
        end
      end
      TBODY do
        TR do
          TH{'A'}
          TH{'B'}
          TH{'C'}
        end
      end
    end
  end
end