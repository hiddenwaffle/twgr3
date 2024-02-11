module InterestBearing
  def calculate_interest
    puts 'Placeholder! InterestBearing'
  end
end

class BankAccount
  include InterestBearing

  def calculate_interest
    puts 'Placeholder! BankAccount'
  end
end

account = BankAccount.new
account.calculate_interest
