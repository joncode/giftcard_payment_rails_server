require 'spec_helper'

describe Positronics do

	describe "gift pos_redeem" do

		it "should redeem gift with correct ticket number" do
			p = FactoryGirl.create(:provider, :pos_merchant_id => "EaTaa5c6", :r_sys => 3)
			u = FactoryGirl.create(:user)
			g = FactoryGirl.create(:gift, receiver_id: u.id, :provider_id => p.id)
			g.notify
      g.balance.should == 10000
      g.detail.should be_nil
			g.value_in_cents.should == 10000
			cents      = g.value_in_cents
			setter_hsh = {"amount_paid" => 1128, "due" => 0, "gift_balance" => (10000 - 1128), "open" => false, "ticket_num" => 553, "total" => 1128, "closed" => true}
			Positronics.any_instance.stub(:get_tickets_at_location).and_return(one_page_resp)
			Positronics.any_instance.stub(:post_redeem).and_return(payment_more(setter_hsh))
			resp = g.pos_redeem(553, "EaTaa5c6")
			puts resp.inspect
			resp["success"].should be_true
			resp["response_code"].should == "OVER_PAID"
			resp["response_text"].should == "Your gift exceeded the check value. Your gift has a balance of $88.72."
      g.reload.status.should == 'notified'
      g.redeemed_at.should   == nil
      g.balance.should       == 8872
      g.detail.should        == "$11.28 was paid with check # 553\n"
      r = g.redemptions.first
      r.gift_id.should == g.id
      r.gift_prev_value.should == 10000
      r.gift_next_value.should == 8872
      r.amount.should          == 1128
      r.type_of.should         == "positronics"
      r.ticket_id.should       == "o6iBA8Tk"
		end

		it "should redeem gift when check and gift are the same value" do
			p = FactoryGirl.create(:provider, :pos_merchant_id => "EaTaa5c6", :r_sys => 3)
			u = FactoryGirl.create(:user)
			g = FactoryGirl.create(:gift, receiver_id: u.id, :provider_id => p.id)
			g.notify
			setter_hsh = {"amount_paid" => 10000, "due" => 0, "gift_balance" => 0, "open" => false, "ticket_num" => 534, "total" => 10000, "closed" => true}
			Positronics.any_instance.stub(:get_tickets_at_location).and_return(one_page_resp)
			Positronics.any_instance.stub(:post_redeem).and_return(payment_more(setter_hsh))
			g.value_in_cents.should > 9900
			resp = g.pos_redeem(534, "EaTaa5c6")
			puts resp.inspect
			resp["success"].should be_true
			resp["response_code"].should == "PAID"
			resp["response_text"].should == "$100.00 was applied to your check. Transaction completed."
			g.reload.status.should == 'redeemed'
			g.redeemed_at.should > 1.hour.ago

		end

		it "should redeem gift when gift is less than check" do
			p = FactoryGirl.create(:provider, :pos_merchant_id => "EaTaa5c6", :r_sys => 3)
			u = FactoryGirl.create(:user)
			g = FactoryGirl.create(:gift, receiver_id: u.id, :provider_id => p.id)
			g.notify
			setter_hsh = {"amount_paid" => 10000, "due" => 1280, "gift_balance" => 0, "open" => true, "ticket_num" => 356, "total" => 10000, "closed" => false}
			Positronics.any_instance.stub(:get_tickets_at_location).and_return(one_page_resp)
			Positronics.any_instance.stub(:post_redeem).and_return(payment_more(setter_hsh))
			g.value_in_cents.should > 9900
			resp = g.pos_redeem(356, "EaTaa5c6")
			puts resp.inspect
			resp["success"].should be_true
			resp["response_code"].should == "APPLIED"
			resp["response_text"].should == "$100.00 was applied to your check. A total of $0.80 remains to be paid."
			g.reload.status.should == 'redeemed'
			g.redeemed_at.should > 1.hour.ago
		end

		it "should redeem gift when gift is less than check" do
			p = FactoryGirl.create(:provider, :pos_merchant_id => "EaTaa5c6", :r_sys => 3)
			u = FactoryGirl.create(:user)
			g = FactoryGirl.create(:gift, receiver_id: u.id, :provider_id => p.id)
			g.notify
			setter_hsh = {"amount_paid" => 10000, "due" => 1128, "gift_balance" => 0, "open" => true, "ticket_num" => 600, "total" => 11128, "closed" => false}
			Positronics.any_instance.stub(:post_redeem).and_return(payment_more(setter_hsh))
			stub_request(:get, "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets").
        with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Api-Key'=>'203d714b6a3642379ce7ccbabe4e9926', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => one_page_resp.to_json, :headers => {})
      both_page_resp = one_page_resp
      both_page_resp["_links"]["prev"] = one_page_resp["_links"]["next"]
      both_page_resp["_links"]["next"]["href"] = "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/?limit=50&start=100"
      stub_request(:get, "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/?limit=50&start=50").
        with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Api-Key'=>'203d714b6a3642379ce7ccbabe4e9926', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => both_page_resp.to_json, :headers => {})
      stub_request(:get, "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/?limit=50&start=100").
        with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Api-Key'=>'203d714b6a3642379ce7ccbabe4e9926', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => second_page_resp.to_json, :headers => {})


      g.value_in_cents.should > 9900
			resp = g.pos_redeem(600, "EaTaa5c6")
			puts resp.inspect
			resp["success"].should be_true
			resp["response_code"].should == "APPLIED"
			resp["response_text"].should == "$100.00 was applied to your check. A total of $11.28 remains to be paid."
			g.reload.status.should == 'redeemed'
			g.redeemed_at.should > 1.hour.ago
		end
	end

end

def payment_more(setter_hsh)
	{
	  "accepted" => true,
	  "amount_paid" => setter_hsh["amount_paid"],
	  "balance_remaining" => setter_hsh["due"],
	  "gift_card_balance" => setter_hsh["gift_balance"],
	  "ticket" => {
	    "auto_send" => true,
	    "closed_at" => 1422763846,
	    "guest_count" => 1,
	    "id" => "8AiKz6Td",
	    "name" => "ItsOnMe check",
	    "open" => setter_hsh["open"],
	    "opened_at" => 1422757650,
	    "ticket_number" => setter_hsh["ticket_num"],
	    "totals" => {
	      "due" => setter_hsh["due"],
	      "other_charges" => 0,
	      "service_charges" => 0,
	      "sub_total" => 1050,
	      "tax" => 78,
	      "total" => setter_hsh["total"]
	    },
	    "void" => false
	  },
	  "ticket_closed" => setter_hsh["closed"]
	}
end


def one_page_resp
{
  "count" => 48,
  "limit" => 50,
  "_links" => {
    "next" => {
      "etag" => "31b2ac5397f0680aaedf665f4959291d",
      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/?limit=50&start=50" ,
      "profile" => "https://panel.positronics.io/docs/#ticket_list"
    },
    "self" => {
      "etag" => "cbc77a268a95f7eec7eb9c86ec9da4d4",
      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/" ,
      "profile" => "https://panel.positronics.io/docs/#ticket_list"
    }
  },
  "_embedded" => {
    "tickets" => [
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "o6iBA8Tk",
        "name" => "ItsOnMe check",
        "open" => true,
        "opened_at" => 1422429323,
        "ticket_number" => 553,
        "totals" => {
          "due" => 1128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "4463b08ffdf90e02cda923b5de01c360",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "8aTpebcB",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/items/8aTpebcB/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "7579d1bea20b6ede3ddaf1470c6f2669",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/items/8aTpebcB/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "6xcEgMiR",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/items/6xcEgMiR/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "7cf43fc933ddd67acce1ab61770933e2",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/items/6xcEgMiR/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "joig75TE",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1422311912,
        "ticket_number" => 535,
        "totals" => {
          "due" => 128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/joig75TE/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/joig75TE/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "c780a1741d0db4abcdfcc9484673d78a",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/joig75TE/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/joig75TE/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "8aTrqrcB",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/joig75TE/items/8aTrqrcB/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "05986e3db32e3dfc2989bba9a20ac2d8",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/joig75TE/items/8aTrqrcB/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "dKc9pGik",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/joig75TE/items/dKc9pGik/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "8f2cb100b69796fce0b49fe2bc7c7e6b",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/joig75TE/items/dKc9pGik/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "qpcxA4iz",
              "_links" => {
                "self" => {
                  "etag" => "3325f055d3db5d876ac129ff060606f0",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/joig75TE/payments/qpcxA4iz/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "LocXyoix",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1422311183,
        "ticket_number" => 534,
        "totals" => {
          "due" => 10000,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 10000
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LocXyoix/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LocXyoix/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "89ce5700f208d18f74d3eefd42ab9845",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LocXyoix/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LocXyoix/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "",
              "id" => "8piRpaTE",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LocXyoix/items/8piRpaTE/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "1bb5ff1a6d0fe40d61e3e118b92923a7",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LocXyoix/items/8piRpaTE/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "Burned",
              "id" => "y4cMRzie",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LocXyoix/items/y4cMRzie/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "b45c9533c148b9c0039ae3d55c9f31e9",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LocXyoix/items/y4cMRzie/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "LKTdjLcq",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1422311114,
        "ticket_number" => 533,
        "totals" => {
          "due" => 28,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTdjLcq/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTdjLcq/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "073be35aa27c59d529f8f62dac51d917",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTdjLcq/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTdjLcq/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "EbiXbRTA",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTdjLcq/items/EbiXbRTA/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "9059fdf330595bf0322555005933cda3",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTdjLcq/items/EbiXbRTA/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "gnTkqGcy",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTdjLcq/items/gnTkqGcy/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "54c66a166cb69a1c00884663cacf2aa1",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTdjLcq/items/gnTkqGcy/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "xBiKrATX",
              "_links" => {
                "self" => {
                  "etag" => "e7aa0be96b9d350826267c0318da3b64",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTdjLcq/payments/xBiKrATX/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            },
            {
              "id" => "MqT9AMcR",
              "_links" => {
                "self" => {
                  "etag" => "7ad7fb04185a69eb2e13eaeca6e00e42",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTdjLcq/payments/MqT9AMcR/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "7LiGKaTq",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1422311020,
        "ticket_number" => 532,
        "totals" => {
          "due" => 1128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LiGKaTq/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LiGKaTq/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "a47d7885cc5f6225fe44e0d9b256233b",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LiGKaTq/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LiGKaTq/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "",
              "id" => "8ac6qMiB",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LiGKaTq/items/8ac6qMiB/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "2a5b92c5fc97d3bc0f14ac202b6fd9d0",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LiGKaTq/items/8ac6qMiB/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "Burned",
              "id" => "d9Typqck",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LiGKaTq/items/d9Typqck/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "d43974561a17b818cdafbc4de133d8a8",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LiGKaTq/items/d9Typqck/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "eKcn8Bix",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1422310290,
        "ticket_number" => 531,
        "totals" => {
          "due" => 1128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKcn8Bix/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKcn8Bix/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "1e15f08fa52e25296466d267c876f571",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKcn8Bix/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKcn8Bix/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "BXc7baip",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKcn8Bix/items/BXc7baip/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "5c677a661e0c5a1a601d07db9c129ae2",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKcn8Bix/items/BXc7baip/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "76izpETk",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKcn8Bix/items/76izpETk/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "bd84260e923fd116ee306d0fbca61f6b",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKcn8Bix/items/76izpETk/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "AxTA9LcA",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1421281399,
        "ticket_number" => 386,
        "totals" => {
          "due" => 1128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/AxTA9LcA/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/AxTA9LcA/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "56110b1f6b53f182b5960e2d4b61047a",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/AxTA9LcA/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/AxTA9LcA/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "",
              "id" => "dKi9zoTk",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/AxTA9LcA/items/dKi9zoTk/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "b090bbc43148a851550cde7db056c1f4",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/AxTA9LcA/items/dKi9zoTk/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "Burned",
              "id" => "Eacjgoie",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/AxTA9LcA/items/Eacjgoie/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "263ee5ce218fb3da284ffb6000b889a7",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/AxTA9LcA/items/Eacjgoie/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "EqiR6ETo",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1421280636,
        "ticket_number" => 385,
        "totals" => {
          "due" => 128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqiR6ETo/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqiR6ETo/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "1d86f0de491e0585240ba160c23c6852",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqiR6ETo/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqiR6ETo/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "y4iMkLTe",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqiR6ETo/items/y4iMkLTe/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "0569a406abbf536b5540b7a2c5bd2cfa",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqiR6ETo/items/y4iMkLTe/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "8pTRyRcE",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqiR6ETo/items/8pTRyRcE/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "540bdad3547fc6de95241fe510f284e3",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqiR6ETo/items/8pTRyRcE/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "KqcyAriR",
              "_links" => {
                "self" => {
                  "etag" => "50df4b9ea5e478a01f25077cf870af25",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqiR6ETo/payments/KqcyAriR/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "eKTnq9cx",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1421190833,
        "ticket_number" => 356,
        "totals" => {
          "due" => 10080,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 10500,
          "tax" => 780,
          "total" => 11280
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKTnq9cx/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKTnq9cx/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "e9c392f26fd61e50aed87f057bb21116",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKTnq9cx/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKTnq9cx/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "BXT77kcp",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKTnq9cx/items/BXT77kcp/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "d44566e2cf6bed0fa92f57921d317f0d",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKTnq9cx/items/BXT77kcp/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "76czgxik",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKTnq9cx/items/76czgxik/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "a70a3147c9f3e77f0cfb2d77cb81611e",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKTnq9cx/items/76czgxik/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "zGc4eBip",
              "_links" => {
                "self" => {
                  "etag" => "eedb803396c3f088beb39948839f5e01",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKTnq9cx/payments/zGc4eBip/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "EqTRrrco",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1421090348,
        "ticket_number" => 341,
        "totals" => {
          "due" => 0,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqTRrrco/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqTRrrco/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "b3e3fd10e56db11003a0f24dd20534e6",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqTRrrco/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqTRrrco/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "",
              "id" => "y4TMyEce",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqTRrrco/items/y4TMyEce/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "714f41550ea9368cfcfafedfca7e95af",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqTRrrco/items/y4TMyEce/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "Burned",
              "id" => "6xiGLKTR",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqTRrrco/items/6xiGLKTR/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "533b1ccbb33d1e7072a94cd15e064183",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqTRrrco/items/6xiGLKTR/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "xBiKk6TX",
              "_links" => {
                "self" => {
                  "etag" => "75e38a3eb94ee042b83619d59fd3bdc2",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqTRrrco/payments/xBiKk6TX/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "LoirpzT7",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1421090311,
        "ticket_number" => 340,
        "totals" => {
          "due" => 8,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LoirpzT7/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LoirpzT7/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "2377f3b12ebf5a22cd633cf74e9ce857",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LoirpzT7/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LoirpzT7/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "6gTdKbcq",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LoirpzT7/items/6gTdKbcq/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "bdd38ced99f3d98d5bae16744744d471",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LoirpzT7/items/6gTdKbcq/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "rGcgdAiz",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LoirpzT7/items/rGcgdAiz/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "d56dc56e0b1d32675150cd54a62935ec",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LoirpzT7/items/rGcgdAiz/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "Mqc9x6iR",
              "_links" => {
                "self" => {
                  "etag" => "fa0444fa091ef07beb323e7b04dcdf6a",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LoirpzT7/payments/Mqc9x6iR/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "g9cxqzid",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1421090280,
        "ticket_number" => 339,
        "totals" => {
          "due" => 78,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9cxqzid/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9cxqzid/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "a3929471b97cd4c56f1d366240b613b8",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9cxqzid/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9cxqzid/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "bpcKGRi5",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9cxqzid/items/bpcKGRi5/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "617db41a5c3542838f80a83cb98ca19e",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9cxqzid/items/bpcKGRi5/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "jEiAzgT8",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9cxqzid/items/jEiAzgT8/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "dfb668fcc655ecd30bdfbf148ece1847",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9cxqzid/items/jEiAzgT8/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "qpTxyLcz",
              "_links" => {
                "self" => {
                  "etag" => "6fccaa7d1790a12c37c67d9b9cfa95ad",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9cxqzid/payments/qpTxyLcz/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "B9Tke4cL",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1421089663,
        "ticket_number" => 338,
        "totals" => {
          "due" => 0,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tke4cL/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tke4cL/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "fadbe18030ce5b1688b8a04e543a31f6",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tke4cL/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tke4cL/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "gnikKrTy",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tke4cL/items/gnikKrTy/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "bd099365b9b323faea7c852321bb9f70",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tke4cL/items/gnikKrTy/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "d9TyBbck",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tke4cL/items/d9TyBbck/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "7f8ffe0cc0eba8b79b601a801c61f29f",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tke4cL/items/d9TyBbck/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "zGi4rjTp",
              "_links" => {
                "self" => {
                  "etag" => "ea5b037770f85135074637184c64d299",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tke4cL/payments/zGi4rjTp/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "LKideoTq",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1421089631,
        "ticket_number" => 337,
        "totals" => {
          "due" => 0,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKideoTq/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKideoTq/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "2509bed869b8bf0362fca95a1887c248",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKideoTq/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKideoTq/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "BXT7aXcp",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKideoTq/items/BXT7aXcp/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "00ac7528baedbe9e5d18e2f9b14403d5",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKideoTq/items/BXT7aXcp/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "8acraRiB",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKideoTq/items/8acraRiB/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "3b7ac5ac981bfcd42f8c29d2508627a3",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKideoTq/items/8acraRiB/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "75caKriA",
              "_links" => {
                "self" => {
                  "etag" => "fd51e2cb527256240bdf94205f52072a",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKideoTq/payments/75caKriA/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "8AcKnEid",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1421089598,
        "ticket_number" => 336,
        "totals" => {
          "due" => 128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AcKnEid/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AcKnEid/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "5531d79c6df4c61590243df18435ecf5",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AcKnEid/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AcKnEid/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "",
              "id" => "8ai6aXTB",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AcKnEid/items/8ai6aXTB/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "f91dd22c129e203600f3f4756bc7acc8",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AcKnEid/items/8ai6aXTB/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "Burned",
              "id" => "y4cMGzie",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AcKnEid/items/y4cMGzie/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "3bb686a1081d1acca18f4075420c9a33",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AcKnEid/items/y4cMGzie/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "qxT7jdcz",
              "_links" => {
                "self" => {
                  "etag" => "3a962d23f8943d593993a04fb4c768f1",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AcKnEid/payments/qxT7jdcz/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "g9T8qAcd",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1421089550,
        "ticket_number" => 335,
        "totals" => {
          "due" => 0,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9T8qAcd/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9T8qAcd/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "0cb7bd846955d04f106875b63ff3a07d",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9T8qAcd/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9T8qAcd/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "76izBdTk",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9T8qAcd/items/76izBdTk/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "4e6cbf62548d3a4c4bb552d4e1d95bcd",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9T8qAcd/items/76izBdTk/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "6xTG7qcR",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9T8qAcd/items/6xTG7qcR/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "9fd0941d23ee68c5e9a3224febff85a6",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9T8qAcd/items/6xTG7qcR/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "zGi4rETp",
              "_links" => {
                "self" => {
                  "etag" => "89a560e5415226cbde4464f237a47286",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9T8qAcd/payments/zGi4rETp/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "o6iByeTk",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1421089524,
        "ticket_number" => 334,
        "totals" => {
          "due" => 1008,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iByeTk/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iByeTk/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "a8f12c3d1079367975439b75572a1fd2",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iByeTk/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iByeTk/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "jETAz5c8",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iByeTk/items/jETAz5c8/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "21d557880e2fc8ee029eb9914774f14d",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iByeTk/items/jETAz5c8/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "EbcXyXiA",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iByeTk/items/EbcXyXiA/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "1363db5763c485462eb0ad7f890455e3",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iByeTk/items/EbcXyXiA/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "6qcAKBiL",
              "_links" => {
                "self" => {
                  "etag" => "2ca3916618a41b9d3b97d7dd346e4f40",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iByeTk/payments/6qcAKBiL/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "g9czqzid",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1421089505,
        "ticket_number" => 333,
        "totals" => {
          "due" => 1128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czqzid/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czqzid/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "04bc8614b73ec04246c5100255e583d3",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czqzid/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czqzid/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "d9cyBBik",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czqzid/items/d9cyBBik/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "a7e10049f85fbdf542376b4f9d70f1f2",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czqzid/items/d9cyBBik/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "bpiKG6T5",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czqzid/items/bpiKG6T5/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "79f27dfd702d1392715bad9cf025690e",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czqzid/items/bpiKG6T5/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "B9ToeqcL",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1421089456,
        "ticket_number" => 332,
        "totals" => {
          "due" => 0,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9ToeqcL/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9ToeqcL/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "c863e8720e7efd7ee3d8947dc8f7a5a9",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9ToeqcL/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9ToeqcL/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "Eaij7ATe",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9ToeqcL/items/Eaij7ATe/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "1ba504f7ce7523746d5b39369155a396",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9ToeqcL/items/Eaij7ATe/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "gnTkK5cy",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9ToeqcL/items/gnTkK5cy/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "ad6b2a4e1f3d1c26e5fe16d31b945ea5",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9ToeqcL/items/gnTkK5cy/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "zxTj74ce",
              "_links" => {
                "self" => {
                  "etag" => "a9f68d6b6f08c3b049bc7526b76d2c23",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9ToeqcL/payments/zxTj74ce/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "z6cydLid",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1420853712,
        "ticket_number" => 306,
        "totals" => {
          "due" => 0,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/z6cydLid/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/z6cydLid/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "02b58942724ddd7e8cb143f723a53437",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/z6cydLid/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/z6cydLid/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "",
              "id" => "jEiAydT8",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/z6cydLid/items/jEiAydT8/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "9a98960a81a33b9ceffec643da76f0ba",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/z6cydLid/items/jEiAydT8/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "Burned",
              "id" => "bpcKzyi5",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/z6cydLid/items/bpcKzyi5/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "a06d842e7d7964b9f56f1778ed1096e7",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/z6cydLid/items/bpcKzyi5/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "y5czbEio",
              "_links" => {
                "self" => {
                  "etag" => "95836325b2e3812b8d05fc2cfc8856cf",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/z6cydLid/payments/y5czbEio/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "B9Tk7AcL",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1420853639,
        "ticket_number" => 305,
        "totals" => {
          "due" => 0,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tk7AcL/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tk7AcL/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "ba6f386b44817d5e85e1f6b60fb66c90",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tk7AcL/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tk7AcL/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "kxiaAMTo",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tk7AcL/items/kxiaAMTo/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "b7f38437fa910a4a74cef59543191ad8",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tk7AcL/items/kxiaAMTo/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "d9Ty5Eck",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tk7AcL/items/d9Ty5Eck/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "6084056f176a9ab340fbdd9b4d073334",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tk7AcL/items/d9Ty5Eck/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "xBcKeqiX",
              "_links" => {
                "self" => {
                  "etag" => "bed976b5db5cc7f06a2ba1db145fdd92",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tk7AcL/payments/xBcKeqiX/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            },
            {
              "id" => "Kqiy84TR",
              "_links" => {
                "self" => {
                  "etag" => "e0ebbcdfd1619816f19137989a86fedd",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tk7AcL/payments/Kqiy84TR/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            },
            {
              "id" => "zGTrGMcp",
              "_links" => {
                "self" => {
                  "etag" => "7fca8644471d5a263853fb99a235c6a4",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9Tk7AcL/payments/zGTrGMcp/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "LKid9RTq",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1420847759,
        "ticket_number" => 304,
        "totals" => {
          "due" => 1006,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKid9RTq/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKid9RTq/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "0f53e5ad6dd6fa3e3cc5a11029070192",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKid9RTq/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKid9RTq/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "XdToAecE",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKid9RTq/items/XdToAecE/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "d7a5ace5428861a78befdabbbb09dec1",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKid9RTq/items/XdToAecE/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "ndcLzkik",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKid9RTq/items/ndcLzkik/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "add02563fa0fa8bb9e86e0839b9415d3",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKid9RTq/items/ndcLzkik/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "zBToyRcr",
              "_links" => {
                "self" => {
                  "etag" => "68940710463e906b03884d4c9e705e7f",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKid9RTq/payments/zBToyRcr/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "qbc7K7iy",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1420847710,
        "ticket_number" => 303,
        "totals" => {
          "due" => 1116,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/qbc7K7iy/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/qbc7K7iy/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "f4a1c5b62641b925f20ae28e2092936f",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/qbc7K7iy/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/qbc7K7iy/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "",
              "id" => "Kei5XeTM",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/qbc7K7iy/items/Kei5XeTM/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "a4b7c069e4b96d593fcfa3a515664468",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/qbc7K7iy/items/Kei5XeTM/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "Burned",
              "id" => "eMcB7aiy",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/qbc7K7iy/items/eMcB7aiy/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "fa2fdafa9fd6b45bf216a522fde773bf",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/qbc7K7iy/items/eMcB7aiy/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "qpixbrTz",
              "_links" => {
                "self" => {
                  "etag" => "8966f2562ca4e2991cd8408d1992d239",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/qbc7K7iy/payments/qpixbrTz/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "68T4E4cr",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1420847430,
        "ticket_number" => 302,
        "totals" => {
          "due" => 1117,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/68T4E4cr/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/68T4E4cr/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "c9f514bfdade418cb1cdcb015d2172c9",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/68T4E4cr/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/68T4E4cr/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "BRi4XXTq",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/68T4E4cr/items/BRi4XXTq/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "13653917ca3fdbc77aaebfcc92f52d98",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/68T4E4cr/items/BRi4XXTq/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "dKT954ck",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/68T4E4cr/items/dKT954ck/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "df69a9e6c7de60738c6c547e78a7fcb0",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/68T4E4cr/items/dKT954ck/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "zGc4GXip",
              "_links" => {
                "self" => {
                  "etag" => "91264afd32be9f277b714400ef2a5e2a",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/68T4E4cr/payments/zGc4GXip/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "eKing5Tx",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1420847378,
        "ticket_number" => 301,
        "totals" => {
          "due" => 1116,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKing5Tx/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKing5Tx/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "aed3353b8932e7922f54c3eac064db46",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKing5Tx/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKing5Tx/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "jETAyxc8",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKing5Tx/items/jETAyxc8/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "465b06d93028e4ba2dfa051fff644cf6",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKing5Tx/items/jETAyxc8/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "EbcXBaiA",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKing5Tx/items/EbcXBaiA/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "e8609f5ce6693f33aafeefa6393a5bc8",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKing5Tx/items/EbcXBaiA/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "75TajpcA",
              "_links" => {
                "self" => {
                  "etag" => "e675cc457b667cb9711183001061ee05",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/eKing5Tx/payments/75TajpcA/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "g9czn5id",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1420846994,
        "ticket_number" => 300,
        "totals" => {
          "due" => 0,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czn5id/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czn5id/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "e5317457915f4f7789a95b338a2cc15d",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czn5id/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czn5id/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "BXc75Eip",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czn5id/items/BXc75Eip/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "77f599f963cf754a3284382a4559f4ee",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czn5id/items/BXc75Eip/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "bpiKzrT5",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czn5id/items/bpiKzrT5/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "4af691d4d6ff0dd5b73a02dd68e30419",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czn5id/items/bpiKzrT5/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "qpixb6Tz",
              "_links" => {
                "self" => {
                  "etag" => "887f2fea343f53008be3c78251c02622",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9czn5id/payments/qpixb6Tz/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "7LTEd6cq",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1420846963,
        "ticket_number" => 299,
        "totals" => {
          "due" => 128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LTEd6cq/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LTEd6cq/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "cd67b13b03fc4380b3e99fe1275a3d28",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LTEd6cq/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LTEd6cq/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "y4iM7XTe",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LTEd6cq/items/y4iM7XTe/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "70a25b022550145972f1ca496b5c6040",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LTEd6cq/items/y4iM7XTe/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "8aT65zcB",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LTEd6cq/items/8aT65zcB/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "6d6bf5d6cc491c3f00d6da31e112052a",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LTEd6cq/items/8aT65zcB/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "47c8bBi7",
              "_links" => {
                "self" => {
                  "etag" => "da5e8612cd1ca2264ac2913143d97437",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LTEd6cq/payments/47c8bBi7/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "4yiq5bTn",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1420837123,
        "ticket_number" => 295,
        "totals" => {
          "due" => 0,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/4yiq5bTn/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/4yiq5bTn/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "b738bcb7993239a1f375bd0b2bfaefe1",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/4yiq5bTn/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/4yiq5bTn/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "",
              "id" => "ndcLz4ik",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/4yiq5bTn/items/ndcLz4ik/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "073cba727f3080a7365d2b0726384810",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/4yiq5bTn/items/ndcLz4ik/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "Burned",
              "id" => "8aTrnocB",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/4yiq5bTn/items/8aTrnocB/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "4bafc2595686d6a769d2e05a63fdbd45",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/4yiq5bTn/items/8aTrnocB/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "zqikX9T4",
              "_links" => {
                "self" => {
                  "etag" => "1da32278f1a14197e24a828ebffb882f",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/4yiq5bTn/payments/zqikX9T4/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            },
            {
              "id" => "MzTGaycL",
              "_links" => {
                "self" => {
                  "etag" => "1f5afbe21721a414e55e13246ca40169",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/4yiq5bTn/payments/MzTGaycL/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "byca7oiB",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1420836947,
        "ticket_number" => 294,
        "totals" => {
          "due" => 0,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/byca7oiB/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/byca7oiB/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "12baf06b2341beeb99f1d2b007530d1a",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/byca7oiB/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/byca7oiB/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "8ac6nqiB",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/byca7oiB/items/8ac6nqiB/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "bebe3c532d405dc79f49fc24ec2dcf80",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/byca7oiB/items/8ac6nqiB/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "BXi7nzTp",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/byca7oiB/items/BXi7nzTp/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "4a49da088fed9e470abd04aef8dab9ea",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/byca7oiB/items/BXi7nzTp/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "EqcBKni5",
              "_links" => {
                "self" => {
                  "etag" => "a2888129e7e145b12d2152d0303ba70c",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/byca7oiB/payments/EqcBKni5/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "o6TBkack",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1420836835,
        "ticket_number" => 293,
        "totals" => {
          "due" => 0,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBkack/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBkack/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "21e1f7c51189b139789ed72d39fed878",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBkack/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBkack/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "6xiGXaTR",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBkack/items/6xiGXaTR/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "1e57d9697e104018f6f7dfce5e4dacd6",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBkack/items/6xiGXaTR/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "y4TMaece",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBkack/items/y4TMaece/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "d285c1c73037d4f19bb872d06a7cabf7",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBkack/items/y4TMaece/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "6qiALeTL",
              "_links" => {
                "self" => {
                  "etag" => "0d71675af8758f3016f4eaa944b95d52",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBkack/payments/6qiALeTL/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            },
            {
              "id" => "GrTqBocR",
              "_links" => {
                "self" => {
                  "etag" => "3bb803a997b7495b96de5cbbb1727841",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBkack/payments/GrTqBocR/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "g9i8LoTd",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1420484669,
        "ticket_number" => 187,
        "totals" => {
          "due" => 828,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8LoTd/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8LoTd/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "61253bd70046d1139d1e12fac44617d8",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8LoTd/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8LoTd/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "",
              "id" => "EaTjekce",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8LoTd/items/EaTjekce/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "33401211cab755630b4078f925b0937b",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8LoTd/items/EaTjekce/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "Burned",
              "id" => "BXi78qTp",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8LoTd/items/BXi78qTp/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "95b33534bb236cf13b7bff74e5892e90",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8LoTd/items/BXi78qTp/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "G9cgr5ir",
              "_links" => {
                "self" => {
                  "etag" => "2539592756170396945590ac501f07d0",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8LoTd/payments/G9cgr5ir/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "o6cBGGik",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1420482982,
        "ticket_number" => 186,
        "totals" => {
          "due" => 128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBGGik/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBGGik/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "4af32701a728cf3eeea95bbd774c790a",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBGGik/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBGGik/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "eMTBbrcy",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBGGik/items/eMTBbrcy/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "c509b9f45ab0f2b0dae80c838054d699",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBGGik/items/eMTBbrcy/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "8ac68riB",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBGGik/items/8ac68riB/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "e184ec3519f16c3db94aeaa6d5cbb13a",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBGGik/items/8ac68riB/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "qgT6k8ca",
              "_links" => {
                "self" => {
                  "etag" => "54ceb16b3cc48b3ed1bc76a6a87f7d00",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBGGik/payments/qgT6k8ca/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "EqcRxeio",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1419895441,
        "ticket_number" => 171,
        "totals" => {
          "due" => 828,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqcRxeio/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqcRxeio/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "145679d74e5bb9b1c731ae182e14b2da",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqcRxeio/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqcRxeio/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "EaTjjnce",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqcRxeio/items/EaTjjnce/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "e12b8d18d5a35dac9c64997b81c007af",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqcRxeio/items/EaTjjnce/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "gnck4diy",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqcRxeio/items/gnck4diy/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "3e017f7922afd5ebe70fdf03023b15b1",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqcRxeio/items/gnck4diy/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "MziEakTL",
              "_links" => {
                "self" => {
                  "etag" => "85321ed4aebb0eae72d63c89bcf0b152",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/EqcRxeio/payments/MziEakTL/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "g9c8Aaid",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1419877492,
        "ticket_number" => 165,
        "totals" => {
          "due" => 1008,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9c8Aaid/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9c8Aaid/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "327ed226d584dc41c847da449a68a97f",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9c8Aaid/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9c8Aaid/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "",
              "id" => "EacjjBie",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9c8Aaid/items/EacjjBie/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "4d46e0f4e6111493b6ffc2db2c77e68a",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9c8Aaid/items/EacjjBie/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "Burned",
              "id" => "BXT7y8cp",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9c8Aaid/items/BXT7y8cp/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "d3a32a0b8629c20f15b269d6c1aa9e78",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9c8Aaid/items/BXT7y8cp/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "x7cn4qiE",
              "_links" => {
                "self" => {
                  "etag" => "dd5a38dce31837bbce8d6ecf313030d3",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9c8Aaid/payments/x7cn4qiE/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "o6TBXqck",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1419877221,
        "ticket_number" => 164,
        "totals" => {
          "due" => 888,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBXqck/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBXqck/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "abaaa84b9fb9bdd5adda9249c63dd3ea",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBXqck/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBXqck/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "eMcBGkiy",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBXqck/items/eMcBGkiy/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "8a36819b6a2e0b46694e32c05bf2830e",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBXqck/items/eMcBGkiy/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "8ai677TB",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBXqck/items/8ai677TB/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "7ff92c7c93ced8d58f0051d797537fa1",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBXqck/items/8ai677TB/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "MziGaxTL",
              "_links" => {
                "self" => {
                  "etag" => "847118bb3e9114023bbb146756e4a655",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBXqck/payments/MziGaxTL/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            },
            {
              "id" => "47T8bKc7",
              "_links" => {
                "self" => {
                  "etag" => "70176b2f8cb2af0017464df6fde1bf04",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6TBXqck/payments/47T8bKc7/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "g9izA4Td",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1419846924,
        "ticket_number" => 163,
        "totals" => {
          "due" => 128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9izA4Td/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9izA4Td/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "292caaade05f2967c7fd4cbc5a766e1a",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9izA4Td/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9izA4Td/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "BRi4z9Tq",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9izA4Td/items/BRi4z9Tq/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "51c7faff46bddf884275df144b356d93",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9izA4Td/items/BRi4z9Tq/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "gnTb5ncy",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9izA4Td/items/gnTb5ncy/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "0cb4a804025f4d456e7334f404bd7610",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9izA4Td/items/gnTb5ncy/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "zxcjMeie",
              "_links" => {
                "self" => {
                  "etag" => "9a2b36ad3f0c5f96a0243c132b8fce5f",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9izA4Td/payments/zxcjMeie/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "LKcdAMiq",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1419846495,
        "ticket_number" => 156,
        "totals" => {
          "due" => 1117,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKcdAMiq/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKcdAMiq/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "e27f91dc7e83a6149aa1c91f8b26e369",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKcdAMiq/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKcdAMiq/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "8aTrGrcB",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKcdAMiq/items/8aTrGrcB/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "87b0400126d20f65f0d2b5b77f975e40",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKcdAMiq/items/8aTrGrcB/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "ndcLLMik",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKcdAMiq/items/ndcLLMik/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "31fddc6ad07ae4c747012c0604373650",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKcdAMiq/items/ndcLLMik/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "ybcbyczd",
              "_links" => {
                "self" => {
                  "etag" => "59165fd0788107e28de6c03102d53045",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKcdAMiq/payments/ybcbyczd/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "MoceB5ix",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1418841332,
        "ticket_number" => 141,
        "totals" => {
          "due" => 878,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoceB5ix/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoceB5ix/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "ff0c8acca6051231a858f32784dfad63",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoceB5ix/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoceB5ix/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "",
              "id" => "8pcRXEiE",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoceB5ix/items/8pcRXEiE/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "edabed7ff7ebd2a8f882c0008ffec02f",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoceB5ix/items/8pcRXEiE/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "Burned",
              "id" => "bpTKA8c5",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoceB5ix/items/bpTKA8c5/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "36421ab9273c2805fda083fbb8fb6ebd",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoceB5ix/items/bpTKA8c5/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "qpixrizB",
              "_links" => {
                "self" => {
                  "etag" => "09af56a4350fe900c63dcf6dacebde64",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoceB5ix/payments/qpixrizB/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "7LcGeRiq",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1418807190,
        "ticket_number" => 138,
        "totals" => {
          "due" => 128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LcGeRiq/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LcGeRiq/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "6e4ce5e438a6c9f77e80b25db5c1a809",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LcGeRiq/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LcGeRiq/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "eMTBo4cy",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LcGeRiq/items/eMTBo4cy/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "58b15ffaac24c2648da8ed69b8a6f1a0",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LcGeRiq/items/eMTBo4cy/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "Kec5MriM",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LcGeRiq/items/Kec5MriM/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "34e8d1f47e58ea903d7c8c72f6187aae",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LcGeRiq/items/Kec5MriM/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "zxcjrceM",
              "_links" => {
                "self" => {
                  "etag" => "4425576aa613040d4013d5dd529a74b7",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LcGeRiq/payments/zxcjrceM/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            },
            {
              "id" => "MziGoiLG",
              "_links" => {
                "self" => {
                  "etag" => "18bd2f3fa81eec5b2d3e66f4a3616121",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/7LcGeRiq/payments/MziGoiLG/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "M4T5RdcM",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1418806870,
        "ticket_number" => 134,
        "totals" => {
          "due" => 1128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/M4T5RdcM/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/M4T5RdcM/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "3c266693ca01dfc64a03be41d44fca32",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/M4T5RdcM/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/M4T5RdcM/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "Eacj48ie",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/M4T5RdcM/items/Eacj48ie/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "c4db752d98101d60b3608e220733eebf",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/M4T5RdcM/items/Eacj48ie/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "gnikn4Ty",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/M4T5RdcM/items/gnikn4Ty/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "d87d58bb323ebe5a20ff68217b04bf1c",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/M4T5RdcM/items/gnikn4Ty/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "8AiKr8Td",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1418806681,
        "ticket_number" => 133,
        "totals" => {
          "due" => 1128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AiKr8Td/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AiKr8Td/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "7dee023999e9e629a0346f203da33665",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AiKr8Td/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AiKr8Td/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "8ai6zjTB",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AiKr8Td/items/8ai6zjTB/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "7af4906cb28893b60ae78451b248c028",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AiKr8Td/items/8ai6zjTB/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "BXT7MMcp",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AiKr8Td/items/BXT7MMcp/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "a97cb28c14e3b5bf3b2b25e91db428d3",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/8AiKr8Td/items/BXT7MMcp/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "MoieB4Tx",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1418806256,
        "ticket_number" => 130,
        "totals" => {
          "due" => 1128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoieB4Tx/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoieB4Tx/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "d811bf8a2ce48240eb7eab3625056e8b",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoieB4Tx/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoieB4Tx/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "",
              "id" => "8pTRX7cE",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoieB4Tx/items/8pTRX7cE/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "e39d5159d05ddb5be24092219d5af16a",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoieB4Tx/items/8pTRX7cE/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "Burned",
              "id" => "8aipzBTB",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoieB4Tx/items/8aipzBTB/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "4a3386f306222d031c030fd1dc9ab758",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/MoieB4Tx/items/8aipzBTB/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "B9coRLiL",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1418806237,
        "ticket_number" => 129,
        "totals" => {
          "due" => 1128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9coRLiL/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9coRLiL/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "f240cdf487d0739c13842a72c3830169",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9coRLiL/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9coRLiL/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "gnTk9ocy",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9coRLiL/items/gnTk9ocy/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "a6e3abcd8fa3606ff398d3b725a24694",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9coRLiL/items/gnTk9ocy/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "rGce5Aiz",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9coRLiL/items/rGce5Aiz/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "1010402c112e822d700f7938108d2ede",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/B9coRLiL/items/rGce5Aiz/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "LKTbR4cq",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1418806208,
        "ticket_number" => 128,
        "totals" => {
          "due" => 128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTbR4cq/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTbR4cq/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "a3ba53a55f2ff90d4502ff27b85a8b6c",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTbR4cq/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTbR4cq/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "BXc7Abip",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTbR4cq/items/BXc7Abip/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "5ce065e805c3f86521ef65a30d7fbd46",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTbR4cq/items/BXc7Abip/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "EaijKRTe",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTbR4cq/items/EaijKRTe/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "8093057df2eea15a88831e83d8b97487",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTbR4cq/items/EaijKRTe/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [
            {
              "id" => "zBcdgcrM",
              "_links" => {
                "self" => {
                  "etag" => "790f1c782f50d9e3546c66d6a5f45364",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTbR4cq/payments/zBcdgcrM/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            },
            {
              "id" => "y5iXqiEE",
              "_links" => {
                "self" => {
                  "etag" => "aed7db54a57f2c1c017e5f5439e6d450",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/LKTbR4cq/payments/y5iXqiEE/" ,
                  "profile" => "https://panel.positronics.io/docs/#payment_retrieve"
                }
              }
            }
          ],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "g9TxRAcd",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1418805537,
        "ticket_number" => 125,
        "totals" => {
          "due" => 1128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9TxRAcd/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9TxRAcd/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "0c08530c2b7b678918b67809ec1949b8",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9TxRAcd/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9TxRAcd/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "8pcRAGiE",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9TxRAcd/items/8pcRAGiE/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "70ea053568581d2c2cdcf567dc45c117",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9TxRAcd/items/8pcRAGiE/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "6gid9jTq",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9TxRAcd/items/6gid9jTq/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "7c120eadb72302e9c37220758ba80e79",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9TxRAcd/items/6gid9jTq/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "g9i8R9Td",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1418805282,
        "ticket_number" => 121,
        "totals" => {
          "due" => 1128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8R9Td/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8R9Td/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "42a77e177e208a8e4affd88bf4f664f1",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8R9Td/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8R9Td/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "",
              "id" => "y4TMXBce",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8R9Td/items/y4TMXBce/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "e888dddebf752c53be63d944ab7926ea",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8R9Td/items/y4TMXBce/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "Burned",
              "id" => "dKi9j5Tk",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8R9Td/items/dKi9j5Tk/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "29cecd2f2be31efb9577f6b033382769",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9i8R9Td/items/dKi9j5Tk/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "o6cBexik",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1418805185,
        "ticket_number" => 120,
        "totals" => {
          "due" => 1128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBexik/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBexik/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "3ae86d26658336bd81805f0fdd46bebf",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBexik/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBexik/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "6gTd9gcq",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBexik/items/6gTd9gcq/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "4ce4cdf49b9c1202af3968c143e092b7",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBexik/items/6gTd9gcq/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "76czjnik",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBexik/items/76czjnik/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "21469fc2496fd4a3ef5d5cdd381ae11e",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6cBexik/items/76czjnik/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      },
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "g9Tzz7cd",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1418805010,
        "ticket_number" => 119,
        "totals" => {
          "due" => 1128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 1050,
          "tax" => 78,
          "total" => 1128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9Tzz7cd/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9Tzz7cd/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "0fedbbab9141c63a1a87fb5e3989c831",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9Tzz7cd/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9Tzz7cd/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "bpcKXxi5",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9Tzz7cd/items/bpcKXxi5/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "f1fb74f435f6c13571b66bb04bbe6043",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9Tzz7cd/items/bpcKXxi5/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "8piRAzTE",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9Tzz7cd/items/8piRAzTE/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "27465440e5f1dcb897a3ac1222ed331e",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/g9Tzz7cd/items/8piRAzTE/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      }
    ]
  }
}
end

def second_page_resp
{
  "count" => 2,
  "limit" => 50,
  "_links" => {
    "next" => {
      "etag" => "31b2ac5397f0680aaedf665f4959291d",
      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/?limit=50&start=50" ,
      "profile" => "https://panel.positronics.io/docs/#ticket_list"
    },
    "self" => {
      "etag" => "cbc77a268a95f7eec7eb9c86ec9da4d4",
      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/" ,
      "profile" => "https://panel.positronics.io/docs/#ticket_list"
    }
  },
  "_embedded" => {
    "tickets" => [
      {
        "auto_send" => true,
        "closed_at" => nil,
        "guest_count" => 1,
        "id" => "o6iBA8Tk",
        "name" => "ItsOnMe ticket",
        "open" => true,
        "opened_at" => 1422429323,
        "ticket_number" => 600,
        "totals" => {
          "due" => 11128,
          "other_charges" => 0,
          "service_charges" => 0,
          "sub_total" => 10348,
          "tax" => 780,
          "total" => 11128
        },
        "void" => false,
        "_links" => {
          "items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/items/" ,
            "profile" => "https://panel.positronics.io/docs/#item_list"
          },
          "payments" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/payments/" ,
            "profile" => "https://panel.positronics.io/docs/#payment_list"
          },
          "self" => {
            "etag" => "4463b08ffdf90e02cda923b5de01c360",
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/" ,
            "profile" => "https://panel.positronics.io/docs/#ticket_retrieve"
          },
          "table" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
            "profile" => "https://panel.positronics.io/docs/#table_retrieve"
          },
          "voided_items" => {
            "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/voided_items/" ,
            "profile" => "https://panel.positronics.io/docs/#voided-item_list"
          }
        },
        "_embedded" => {
          "employee" => {
            "check_name" => "Bob",
            "first_name" => "Bob",
            "id" => "BdTaKT4X",
            "last_name" => "Belcher",
            "login" => "100",
            "_links" => {
              "self" => {
                "etag" => "934d3a9ae389e3279fd443cdb05f80cc",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/employees/BdTaKT4X/" ,
                "profile" => "https://panel.positronics.io/docs/#employee_retrieve"
              }
            }
          },
          "items" => [
            {
              "comment" => "Burned",
              "id" => "8aTpebcB",
              "name" => "Mozzarella Sticks",
              "price_level" => "Bycnrcdy",
              "price_per_unit" => 425,
              "quantity" => 2,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/items/8aTpebcB/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "7579d1bea20b6ede3ddaf1470c6f2669",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/items/8aTpebcB/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "recb5cKX",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Mozzarella Sticks",
                  "price" => 425,
                  "price_levels" => [
                    {
                      "id" => "Bycnrcdy",
                      "price" => 425
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "b2b730e6b62660ace2ede0335b5df014",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/recb5cKX/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            },
            {
              "comment" => "",
              "id" => "6xcEgMiR",
              "name" => "Soda",
              "price_level" => "g4T4dTBj",
              "price_per_unit" => 200,
              "quantity" => 1,
              "sent" => true,
              "_links" => {
                "menu_item" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                  "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                },
                "modifiers" => {
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/items/6xcEgMiR/modifiers/" ,
                  "profile" => "https://panel.positronics.io/docs/#modifier_list"
                },
                "self" => {
                  "etag" => "7cf43fc933ddd67acce1ab61770933e2",
                  "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tickets/o6iBA8Tk/items/6xcEgMiR/" ,
                  "profile" => "https://panel.positronics.io/docs/#item_retrieve"
                }
              },
              "_embedded" => {
                "menu_item" => {
                  "id" => "gki84ia9",
                  "in_stock" => true,
                  "modifier_groups_count" => 0,
                  "name" => "Soda",
                  "price" => 150,
                  "price_levels" => [
                    {
                      "id" => "Byineidy",
                      "price" => 150
                    },
                    {
                      "id" => "g4T4dTBj",
                      "price" => 200
                    },
                    {
                      "id" => "K6czkc8b",
                      "price" => 250
                    }
                  ],
                  "_links" => {
                    "modifier_groups" => {
                      "etag" => "d41d8cd98f00b204e9800998ecf8427e",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/modifier_groups/" ,
                      "profile" => "https://panel.positronics.io/docs/#modifier-group_list"
                    },
                    "self" => {
                      "etag" => "7554da25fdabb02e0280ce2838818418",
                      "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/menu/items/gki84ia9/" ,
                      "profile" => "https://panel.positronics.io/docs/#menu-item_retrieve"
                    }
                  }
                },
                "modifiers" => []
              }
            }
          ],
          "order_type" => {
            "available" => true,
            "id" => "KxiAaip5",
            "name" => "Eat In",
            "_links" => {
              "self" => {
                "etag" => "f734af98716581abbfd84b0fc068ade7",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/order_types/KxiAaip5/" ,
                "profile" => "https://panel.positronics.io/docs/#order-type_retrieve"
              }
            }
          },
          "payments" => [],
          "revenue_center" => {
            "default" => true,
            "id" => "LdiqGibo",
            "name" => "Dining",
            "_links" => {
              "self" => {
                "etag" => "5e318e125638f546b0b53d5ebd661813",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/revenue_centers/LdiqGibo/" ,
                "profile" => "https://panel.positronics.io/docs/#revenue-center_retrieve"
              }
            }
          },
          "table" => {
            "available" => true,
            "id" => "x4TdoTd8",
            "name" => "2",
            "number" => 2,
            "seats" => 4,
            "_links" => {
              "self" => {
                "etag" => "258cbb9870f27551f253235561970b97",
                "href" => "https://api.positronics.io/0.1/locations/EaTaa5c6/tables/x4TdoTd8/" ,
                "profile" => "https://panel.positronics.io/docs/#table_retrieve"
              }
            }
          },
          "voided_items" => []
        }
      }
    ]
  }
}
end