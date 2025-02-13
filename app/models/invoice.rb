class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :merchants

  enum status: [:cancelled, 'in progress', :completed]

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def total_discount
    x = invoice_items.joins(item: {merchant: :bulk_discounts})
    .where('invoice_items.quantity >= bulk_discounts.quantity_threshold')
    .group('invoice_items.id')
    .select('MAX(invoice_items.quantity * invoice_items.unit_price * (bulk_discounts.discount_percent)/100) AS discount')
		x.sum(&:discount)
	end

  def total_discounted_revenue
		total_revenue - total_discount
	end
end
