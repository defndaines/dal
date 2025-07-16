local BankAccount = {}

function BankAccount:new()
	local account = setmetatable({ amount = 0 }, self)
	self.__index = self
	return account
end

function BankAccount:balance()
	return self.amount
end

function BankAccount:deposit(amount)
	assert(not self.closed)
	assert(amount > 0)
	self.amount = self.amount + amount
end

function BankAccount:withdraw(amount)
	assert(not self.closed)
	assert(amount > 0)
	assert(amount <= self.amount)
	self.amount = self.amount - amount
end

function BankAccount:close()
	self.closed = true
end

return BankAccount
