Moolah.controller :graphs do
  
  get :index do
    render 'graphs/index'
  end
  
  get :balance do
    @title = "Balance"
    @graph_options = Transaction::Graph.balance.merge(
      :title => @title
    )
    @graph = "balance"
    render "graphs/show"
  end
  
  get :checking_balance do
    @title = "Checking Balance"
    @graph_options = Transaction::Graph.checking_balance.merge(
      :title => @title
    )
    @graph = "balance"
    render "graphs/show"
  end
  
  get :savings_balance do
    @title = "Savings Balance"
    @graph_options = Transaction::Graph.savings_balance.merge(
      :title => @title
    )
    @graph = "balance"
    render "graphs/show"
  end
  
  get :monthly_income do
    @title = "Monthly Income"
    @graph_options = Transaction::Graph.monthly_income.merge(
      :title => @title
    )
    @graph = "income"
    render "graphs/show"
  end
  
  #get :show, :map => "/graphs/:graph" do
  #  @graph = params[:graph]
  #  @data = Transaction::Graph.send(:"get_#{@graph}_data")
  #  render "graphs/show"
  #end
  
end