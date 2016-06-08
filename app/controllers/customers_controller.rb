require 'will_paginate/array'

class CustomersController < ApplicationController
  before_action :set_customer, only: [:show, :edit, :update, :destroy]
  before_action :authorize_employee!, except: [:show, :new, :create]

  def index
    @customers = Customer.all.order(:name).paginate(:page => params[:page])
  end

  def show
    unless current_user.admin? || current_user.employee?
      authorize_customer!(@customer)
    end

    unless @customer.receipts.nil?
      @receipts = @customer.receipts
        .paginate(:page => params[:page])
    end

    unless @customer.bills.nil?
      @bills = @customer.bills.paginate(:page => params[:page])
    end
  end

  def new
    if !current_user.customer.nil? || current_user.admin?
      redirect_to root_path
    end
    @customer = Customer.new
  end

  def edit
  end

  def search
    unless params[:search][:q].blank?
      @customers = Customer.search(params[:search][:q])
    else
      @customers = Customer.all
    end
    
    @customers = @customers.paginate(:page => params[:page])

    render :index
  end

  def create
    if !current_user.customer.nil? || current_user.admin?
      redirect_to root_path
    end

    sanitized_params = customer_params

    sanitized_params.delete(:type_id) if current_user.admin?
    
    @customer = Customer.new(sanitized_params)

    if @customer.save
      @customer.account = current_user
      @customer.type = CustomerType.first
      @customer.save

      flash[:notice] = "Customer was successfully created."
      redirect_to @customer
    else
      flash.now[:alert] = "Customer was not successfully created."
      render :new
    end
  end

  def update
    if @customer.update(customer_params)
      flash[:notice] = "Customer was successfully updated."
      redirect_to @customer
    else
      flash.now[:alert] = "Customer was not successfully updated."
      render :edit
    end
  end

  def destroy
    @customer.destroy
    flash.now[:notice] = "Customer was successfully destroyed."
    redirect_to rooms_path
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name, :type_id,
      :identity_card, :phone_number, :address)
  end
end

