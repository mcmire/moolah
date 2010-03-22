Moolah.controller :graphs do
  
  get :index do
    render 'graphs/index'
  end
  
  get :daily_balance do
    @title = "Daily Balance"
    @graph_options = Transaction::Graph.daily_balance.merge(:title => @title)
    @graph = "balance"
    render "graphs/show"
  end
  
  get :monthly_balance do
    @title = "Monthly Balance"
    @graph_options = Transaction::Graph.monthly_balance.merge(:title => @title)
    @graph = "balance_by_period"
    render "graphs/show"
  end
  
  get :bimonthly_balance do
    @title = "Bimonthly Balance"
    @graph_options = Transaction::Graph.bimonthly_balance.merge(:title => @title)
    @graph = "balance_by_period"
    render "graphs/show"
  end
  
  get :daily_income_rate do
    @title = "Daily Income Rate"
    @graph_options = Transaction::Graph.daily_income_rate.merge(:title => @title)
    @graph = "income_rate"
    render "graphs/show"
  end
  
  #get :show, :map => "/graphs/:graph" do
  #  @graph = params[:graph]
  #  @data = Transaction::Graph.send(:"get_#{@graph}_data")
  #  render "graphs/show"
  #end
  
end