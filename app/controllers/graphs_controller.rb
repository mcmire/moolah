Moolah.controller :graphs do
  
  get :index do
    render 'graphs/index'
  end
  
  get :balance do
    @data = Transaction::Graph.get_balance_data
    @graph = "balance"
    @title = "Balance"
    render "graphs/show"
  end
  
  get :checking_balance do
    @data = Transaction::Graph.get_checking_balance_data
    @graph = "balance"
    @title = "Checking Balance"
    render "graphs/show"
  end
  
  get :savings_balance do
    @data = Transaction::Graph.get_savings_balance_data
    @graph = "balance"
    @title = "Savings Balance"
    render "graphs/show"
  end
  
  #get :show, :map => "/graphs/:graph" do
  #  @graph = params[:graph]
  #  @data = Transaction::Graph.send(:"get_#{@graph}_data")
  #  render "graphs/show"
  #end
  
end