Moolah.controller :transactions do
  
  restful :index, :map => "(/accounts/:account_id)/transactions" do
    session[:last_account_id] = params[:account_id]
    @account = Account.find_by_webkey(params[:account_id])
    @transactions = (params[:account_id] ? @account.transactions : Transaction).all(:order => "settled_on desc")
    render 'transactions/index'
  end
  
  restful :new, :parent => :account do
    @account = Account.find_by_webkey(params[:account_id])
    @transaction = @account.transactions.build(:amount => 0, :settled_on => Date.today)
    render 'transactions/new'
  end
  restful :create, :parent => :account do
    @account = Account.find_by_webkey(params[:account_id])
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
    @account = Account.find_by_webkey(params[:account_id])
    @transaction = @account.transactions.find(params[:id])
    render 'transactions/edit'
  end
  restful :update, :parent => :account do
    @account = Account.find_by_webkey(params[:account_id])
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
    @account = Account.find_by_webkey(params[:account_id])
    @transaction = @account.transactions.find(params[:id])
    render 'transactions/delete'
  end
  restful :destroy, :parent => :account do
    account = Account.find_by_webkey(params[:account_id])
    transaction = account.transactions.find(params[:id])
    # BUG: Can't use Transaction.destroy(params[:id]) here for some reason
    transaction.destroy
    flash[:success] = "Transaction was successfully deleted."
    redirect url(:transactions, :index, :account_id => session[:last_account_id])
  end
  
  delete :destroy_multiple, :map => "(/accounts/:account_id)/transactions/destroy_multiple" do
    # BUG: MongoMapper's find method doesn't seem to autoconvert an array of id strings (but it does auto-convert a single id)
    ids = Array(params[:to_delete]).map {|id| Mongo::ObjectID.from_string(id) }
    transactions = Transaction.find(ids)
    transactions.each(&:destroy)
    flash[:success] = format_message(transactions.size, "transaction", "successfully deleted.")
    redirect url(:transactions, :index, :account_id => session[:last_account_id])
  end
  
  get :import, :parent => :account do
    @account = Account.find_by_webkey(params[:account_id])
    render 'transactions/import'
  end
  post :import, :parent => :account do
    account = Account.find_by_webkey(params[:account_id])
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
  
  post :dispatch, :map => "(/accounts/:account_id)/transactions/dispatch" do
    if params[:delete_checked]
      if params[:to_delete].present?
        # BUG: MongoMapper's find method doesn't seem to autoconvert an array of id strings (but it does auto-convert a single id)
        @ids = Array(params[:to_delete]).map {|id| Mongo::ObjectID.from_string(id) }
        @transactions = Transaction.find(@ids)
        render "/transactions/delete_multiple"
      else
        flash[:notice] = "You didn't select any transactions to delete."
        redirect url(:transactions, :index, :account_id => session[:last_account_id])
      end
    end
  end
  
end