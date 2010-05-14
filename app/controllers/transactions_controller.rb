Moolah.controller :transactions do
  
  restful :index, :map => "(/accounts/:account_id)/transactions" do
    session[:last_account_id] = params[:account_id]
    @account = Account.where(:webkey => params[:account_id]).first
    transactions = (params[:account_id] ? @account.transactions : Transaction)
    @transactions = transactions.order_by([:settled_on, :desc]).paginate(:page => params[:page], :per_page => 30)
    render 'transactions/index'
  end
  
  restful :new, :parent => :account do
    @account = Account.where(:webkey => params[:account_id]).first
    @transaction = @account.transactions.build(:amount => 0, :settled_on => Date.today)
    render 'transactions/new'
  end
  restful :create, :parent => :account do
    @account = Account.where(:webkey => params[:account_id]).first
    @transaction = @account.transactions.build
    @transaction.attributes = params[:transaction]
    if @transaction.save
      flash[:success] = "Transaction successfully added."
      redirect url(:transactions, :index, :account_id => session[:last_account_id])
    else
      render 'transactions/new'
    end
  end
  
  restful :edit, :parent => :account do
    @account = Account.where(:webkey => params[:account_id]).first
    @transaction = @account.transactions.find(params[:id])
    render 'transactions/edit'
  end
  restful :update, :parent => :account do
    @account = Account.where(:webkey => params[:account_id]).first
    @transaction = @account.transactions.find(params[:id])
    @transaction.attributes = params[:transaction]
    if @transaction.save
      flash[:success] = "Transaction successfully updated."
      redirect url(:transactions, :index, :account_id => session[:last_account_id])
    else
      render 'transactions/edit'
    end
  end
  
  restful :delete, :parent => :account do
    @account = Account.where(:webkey => params[:account_id]).first
    @transaction = @account.transactions.find(params[:id])
    render 'transactions/delete'
  end
  restful :destroy, :parent => :account do
    account = Account.where(:webkey => params[:account_id]).first
    transaction = account.transactions.find(params[:id])
    transaction.destroy
    flash[:success] = "Transaction was successfully deleted."
    redirect url(:transactions, :index, :account_id => session[:last_account_id])
  end
  
  delete :destroy_multiple, :map => "(/accounts/:account_id)/transactions/destroy_multiple" do
    ids = Array(params[:to_delete])
    transactions = Transaction.criteria.in(:_id => ids)
    transactions.each(&:destroy)
    flash[:success] = format_message(ids.size, "transaction", "successfully deleted.")
    redirect url(:transactions, :index, :account_id => session[:last_account_id])
  end
  
  post :dispatch, :map => "(/accounts/:account_id)/transactions/dispatch" do
    if params[:delete_checked]
      if params[:to_delete].present?
        @ids = Array(params[:to_delete])
        @transactions = Transaction.criteria.in(:_id => @ids)
        render "/transactions/delete_multiple"
      else
        flash[:notice] = "You didn't select any transactions to delete."
        redirect url(:transactions, :index, :account_id => session[:last_account_id])
      end
    end
  end
  
  get :import, :parent => :account do
    @account = Account.where(:webkey => params[:account_id]).first
    render 'transactions/import'
  end
  post :import, :parent => :account do
    account = Account.where(:webkey => params[:account_id]).first
    num_transactions_saved = Transaction.import!(params[:file][:tempfile], account)
    if num_transactions_saved == 0
      flash[:notice] = "No transactions were imported!"
    else
      flash[:success] = format_message(num_transactions_saved, "transaction", "successfully imported.")
    end
    redirect url(:transactions, :index, :account_id => params[:account_id])
  end
  
  get :clear do
    Transaction.delete_all
    redirect url(:transactions, :index)
  end
  
end