// This program receives an unsigned binary number and returns its binary value

#include <iostream>
#include <vector>

void printUnsignedBinary(int n)
{
	// Takes an unsigned decimal number and displays the binary equivalant
	std::vector<int> number;	// Holds the digits of the binary number while calculating

	while (n >= 1)
	{
		if (n % 2 == 0)
		{
			number.push_back(0);
		}
		else
		{
			number.push_back(1);
		}

		n /= 2;
	}

	// Output digits from back to front (or rather, in correct order..)
	for (auto i = number.rbegin(); i != number.rend(); i++)
	{
		std::cout << *i;
	}
}

int main()
{
	int input;

	while (true)
	{
		std::cout << "Enter an unsigned decimal integer (or a negative number to quit): ";
		std::cin >> input;

		if (input < 0)
		{
			return 0;
		}

		printUnsignedBinary(input);

		std::cout << std::endl << std::endl;
	}

	return 0;
}