contract Auction {
	//Storage for auction items
	storage { 
		items: Map<u64, AuctionItem>
	}


	struct AuctionItem {
		name: String,
		descriptionL String,
		starting_price: u64,
		highest_bid: Bid,
		end_time: u64
	}

	
	struct Bid {
		bidder: Address,
		amount: u64
	}
	
// Predicate to start auction
predicate create_auction(item_name: String, description: String, start_price: u64, duration: u64) {
	//Input Validation
	assert(duration > 0, "Auction duration must be greater than 0")

	let current_time = block.timestamp();
	let end_time = current_time + duration;

	let auction_id = generate_unique_id(); // need to implement generator function

	// Create an AuctionItem
	let new_auction = AuctionItem {
		name: item_name,
		description: description,
		starting_price: start_price,
		
		//Set the highest bid to the starting price
		highest_bid: Bid {
			bidder: caller(),
			amount: start_price x
		},
		
		end_time: end_time
		// Store the AuctionItem in the 'auctions' map using unique ID

		storage().auctions.insert(auction_id, new_auction);

	};
}

//Predicate to handle bids
predicate place_bid(auction_id: u64, bid_amount: u64) {
	let auction = storage().auctions.get_or_else(&auction_id, || abort("Auction not found"));

	assert(block.timestamp() < auction.end_time, "Auction has ended");
	assert(bid_amount > auction.highest_bid.amount, "Bid amount must be greater than the current highest bid");

	auction.highest_bid.bidder = caller();
	auction.highest_bid.amount = bid_amount;

	storage().auctions.insert(auction_id, *auction); // Update the auction in storage

}

// Predicate to handle auction closure
predicate close_auction(auction_id: u64) {
	
	// Check if end_time has passed
	let auction = storage().auctions.get_or_else(&auction_id, || abort("Auction not found"));
	assert(block.timestamp() >= auction.end_time, "Auction has not ended");
	1
	// Determine the winner (highest bidder)
	let winner = auction.highest_bid.bidder;
	
	// Transfer ownership or payment

	// Remove the auction from storage
	storage().auctions.remove(&auction_id);

}

}
