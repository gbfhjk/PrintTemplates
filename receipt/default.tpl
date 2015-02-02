{#
                            ***Begin Custom Options***
Set any of the options in this section from 'false' to 'true' in order to enable them in the template
#}

{% set chrome_right_margin_fix = false %}       {# Fixes a potential issue where the right side of receipts are cut off in Chrome #}

{# Item Lines #}

{% set per_line_discount = true %}             {# Displays Discounts on each Sale Line #}
{% set per_line_subtotal = false %}             {# Displays Subtotals for each Sale Line (ex. 1 x $5.00) #}
{% set per_line_discounted_subtotal = true %}  {# Strikes out original subtotal and replaces it with discounted total #}
{% set show_custom_sku = false %}               {# Adds SKU column for Custom SKU, if available, on each Sale Line #}
{% set show_manufacturer_sku = false %}         {# Adds SKU column for Manufacturer SKU, if available, on each Sale Line #}

{# Misc. adjustments #}

{% set transaction_item_count = false %}        {# Gives a total quantity of items sold near the bottom of the receipt #}
{% set store_copy_show_lines = false %}         {# Shows Sale Lines on Credit Card Store Copy receipts #}
{% set quote_to_invoice = false %}              {# Changes Quote wording to Invoice in Sales and in Sale Quotes (does not apply to Work Order Quotes) #}
{% set gift_receipt_no_lines = true %}         {# Removes Sale Lines from Gift Receipts #}

{# Customer information #}

{% set display_full_customer_address = false %} {# Displays Customer's full address, if available #}
{% set customer_name_only = false %}            {# Hides all Customer information except for their name #}
{% set show_customer_notes = false %}           {# Displays Notes entered in the Customer's profile #}

{# Customer Account  #}

{% set credit_account_signature = false %}      {# Prints Store Copy with signature line on accounts that use an Account Credit (not Deposit) #}
{% set credit_account_agreement = 'I authorize the above charge to my Credit Account.' %}   {# The text that will display with the signature line #}

{% set hide_customer_layaways = false %}        {# Hides Customer Layaway information at the bottom of receipts #}
{% set hide_customer_specialorders = false %}   {# Hides Customer Special Order information at the bottom of receipts #}
{% set hide_customer_workorders = false %}      {# Hides Customer Work Order information at the bottom of receipts #}
{% set hide_customer_credit_account = false %}  {# Hides Customer Credit Account information at the bottom of receipts #}

{# Logos #}

{% set logo_width = '225px' %}                  {# Default width is 225px. A smaller number will scale logo down #}
{% set multi_shop_logos = false %}              {# Allows multiple logos to be added for separate locations when used with options below #}

{#
    Use the following shop_logo_array to enter all of your locations and the link to the logo image that you have uploaded to the internet.
    Enter your EXACT shop name (Case Sensitive!) in the Quotes after the "name": entry and then enter the URL to your logo after the "logo": entry.
    Be sure to set the multi_shop_logos setting above to true in order to have these logos take effect!
#}

{% set shop_logo_array =
    {
        0:{"name":"Example Shop", "logo_url":"http://logo.url.goes/here.jpg"},
        1:{"name":"", "logo_url":""},
        2:{"name":"", "logo_url":""},
        3:{"name":"", "logo_url":""},
        4:{"name":"", "logo_url":""},
        5:{"name":"", "logo_url":""}
    }
%}


{#
                            ***End Custom Options***

{% extends parameters.print ? "printbase" : "base" %}
{% block extrastyles %}

<!-- default -->

@page { margin: 0px; }

body {
	font: normal 10pt 'Helvetica Neue', Helvetica, Arial, sans-serif;
	margin: 0;
 	padding: 1px; <!-- You need this to make the printer behave -->
}

.store {
	page-break-after: always;
	margin-bottom: 40px;
}

.receipt {
	font: normal 8pt “Helvetica Neue”, Helvetica, Arial, sans-serif;
}

h1 {
	margin: .5em 0 0;
	font-size: 8pt;
	text-align: center;
}

p.date, p.copy {
	font-size: 7pt;
	margin: 0;
	text-align: center;
}

p.details {
	font-size: 8pt;
	text-align: left;
}

h2 {
	border-bottom: 1px solid black;
	text-transform: uppercase;
	font-size: 8pt;
	margin: .5em 0 0;
}

.header {
	text-align: center;
}

.header h3 {
	font-size: 8pt;
	margin: 0;
}

.header img { 
	display: block;
	margin: 8px auto 4px; 
	text-align: center;
}

table {
	margin: 0 0;
	width: 100%;
	border-collapse:collapse;
}

table thead th { text-align: left; }

table tbody th { 
	font-weight: normal; 
	text-align: left; 
	width: 55%;
}

table td.amount, table th.amount {
  width: 30%;
  text-align: right;
}

td.amount { white-space: nowrap; }

table.totals { text-align: right; }
table.payments { text-align: right; }
table.spacer { margin-top: 1em; }
table tr.total td { font-weight: normal; }

table td.amount { padding-left: 10px; }
table td.quantity { padding-left: 10px; }

table.sale 
table.sale thead th

table div.line_description {
	text-align: left;
	font-weight: normal;
}

table div.line_note {
	text-align: left;
	padding-left: 10px;
}

table div.line_serial {
	text-align: left;
	font-weight: normal;
	padding-left: 10px;
}

table.workorders div.line_description {
	font-weight: normal;
	padding-left: 10px;
}

table.workorders div.line_note {
	font-weight: normal;
	padding-left: 10px;
}

table.workorders div.line_serial {
	font-weight: normal;
	padding-left: 20px;
}

table.workorders td.workorder div.line_note {
	font-weight: normal;
	padding-left: 0px;
}

p.thankyou { 
	margin: 0; 
	text-align: center;
}

.note { text-align: center; }

img.barcode {
	display: block;
	margin: 0 auto; 
}

dl {
	overflow: hidden
}

dl dt { 
	font-weight: normal;
	width: 80px;
	float: left
}

dl dd {
	border-top: 2px solid black;
	padding-top: 2px;
	margin: 1em 0 0;
	float: left;
	width: 180px
}

dl dd p { margin: 0; }


{% endblock extrastyles %}

{% block content %}
{% set page_loaded = false %}
{% for Sale in Sales %}

{% if not parameters.page or parameters.page == 1 %}
	{% if Sale.Shop.ReceiptSetup.creditcardAgree|strlen > 0 and not parameters.gift_receipt and not parameters.email %}
		{% if parameters.force_cc_agree or parameters.print_workorder_agree %}
        	{{ _self.store_receipt(Sale,parameters) }}
        	{% set page_loaded = true %}
		{% else %}
	    	{% for SalePayment in Sale.SalePayments.SalePayment %}
        		{% if SalePayment.CCCharge and SalePayment.CCCharge.isDebit == 'false' %}
                	{{ _self.store_receipt(Sale,parameters,SalePayment) }}
                	{% set page_loaded = true %}
        		{% endif %}
        	{% endfor %}
    	{% endif %}
	{% endif %}
{% endif %}

{% if not parameters.page or parameters.page == 2 or not page_loaded %}
<!-- replace.email_custom_header_msg -->
<div>
	{{ _self.ship_to(Sale) }}

	<div class="header">		
		{% if Sale.Shop.ReceiptSetup.hasLogo == 'true' %}
			<img src="{{Sale.Shop.ReceiptSetup.logo}}" width="{{150}}" height="{{100}}" class="logo">
		{% else %}
			<h3>{{ Sale.Shop.name }}</h3>
		{% endif %}
	{% if Sale.Shop.ReceiptSetup.header|strlen > 0 %}
		<p>{{Sale.Shop.ReceiptSetup.header|nl2br|raw}}</p>
	{% else %}
		{{ _self.address(Sale.Shop.Contact) }}
		{% for ContactPhone in Sale.Shop.Contact.Phones.ContactPhone %}
			<br />{{ContactPhone.number}}
		{% endfor %}
	{% endif %}
	</div>

	{{ _self.title(Sale,parameters) }}
	{{ _self.date(Sale) }}
	{{ _self.sale_details(Sale) }}
	{{ _self.receipt(Sale,parameters,true,false) }}

	{% if Sale.quoteID and Sale.Quote.notes|strlen > 0 %}<p class="note quote">{{Sale.Quote.notes|noteformat|raw}}</p>{% endif %}

	{% if Sale.Shop.ReceiptSetup.generalMsg|strlen > 0 %}<p class="note">{{ Sale.Shop.ReceiptSetup.generalMsg|noteformat|raw }}</p>{% endif %}

	{% if not parameters.gift_receipt %}
	<p class="thankyou">Thank You {% if Sale.Customer %}{{Sale.Customer.firstName}} {{Sale.Customer.lastName}}{% endif %}!</p>
	{% endif %}

	<img height="50" width="250" class="barcode" src="/barcode.php?type=receipt&number={{Sale.ticketNumber}}">
</div>

<!-- replace.email_custom_footer_msg -->
{% endif %}
{% endfor %}
{% endblock content %}

{% macro store_receipt(Sale,parameters,Payment) %}
<div class="store">
	<div class="header">
		{{ _self.title(Sale,parameters) }}
		<p class="copy">Store Copy</p>
		{{ _self.date(Sale) }}
	</div>
	
	{{ _self.sale_details(Sale) }}

	<h2>Payments</h2>
	<table class="payments">
		{{ _self.cc_payment_info(Sale,Payment) }}
	</table>

	{% if Sale.quoteID and Sale.Quote.notes|strlen > 0 %}<p class="note quote">{{Sale.Quote.notes|noteformat|raw}}</p>{% endif %}

	{{ _self.cc_agreement(Sale,Payment) }}
	{{ _self.workorder_agreement(Sale) }}

	<img height="50" width="250" class="barcode" src="/barcode.php?type=receipt&number={{Sale.ticketNumber}}">	

	{{ _self.ship_to(Sale) }}
</div>
{% endmacro %}

{% macro lineDescription(Line) %}
	{% if Line.Item %}
		<div class='line_description'>
			{% autoescape true %}{{ Line.Item.description|nl2br }}{% endautoescape %}
		</div>
	{% endif %}
	{%if Line.Note %}
		<div class='line_note'>
			{% autoescape true %}{{ Line.Note.note|noteformat|raw }}{% endautoescape %}
		</div>
	{% endif %}
	{% if Line.Serialized %}
		{% for Serialized in Line.Serialized.Serialized %}
			<div class='line_serial'>
				Serial#: {{ Serialized.serial }} {{ Serialized.color }} {{ Serialized.size }}
			</div>
		{% endfor %}
	{% endif %}
{% endmacro %}


{% macro title(Sale,parameters) %}
<h1>
	{% if Sale.calcTotal >= 0 %}
		{% if Sale.completed == 'true' %}
			{% if parameters.gift_receipt %}Gift{%else%}Sales{%endif%} Receipt
		{% elseif Sale.voided == 'true' %}
			Receipt 
			<large>VOIDED</large>
		{% else %}
			Quote
			{% if not Sale.quoteID %}
				<large>(NOT A RECEIPT)</large>
			{% endif %}
		{% endif %}
	{% else %}
		Refund Receipt
	{% endif %}
</h1>
{% endmacro %}

{% macro date(Sale) %}
<p class="date">
	{% if Sale.timeStamp %}
		{{Sale.timeStamp|correcttimezone|date('m/d/Y h:i:s A')}}
	{% else %}
		{{"now"|date('m/d/Y h:i:s A')}}
	{% endif %}
</p>
{% endmacro %}

{% macro sale_details(Sale) %}
<p class="details">
	{% if Sale.quoteID > 0 %}Quote #: {{Sale.quoteID}}{% endif %}<br />
	Ticket: {{Sale.ticketNumber}}<br />
	{% if Sale.Register %}Register: {{Sale.Register.name}}<br />{% endif %}
	{% if Sale.Employee %}Employee: {{Sale.Employee.firstName}}<br />{% endif %}
	{% if Sale.Customer %}
		{% if Sale.Customer.company|strlen > 0 %}Company: {{Sale.Customer.company}}<br />{% endif %}
		Customer: {{Sale.Customer.firstName}} {{Sale.Customer.lastName}}<br />
		<span class="indent">
		{% for Phone in Sale.Customer.Contact.Phones.ContactPhone %}
		{{Phone.useType}}: {{Phone.number}}<br />
		{% endfor %}
		</span>
	{% endif %}
</p>
{% endmacro %}

{% macro line(Line,parameters) %}
<tr>
	<th>{{ _self.lineDescription(Line) }}</th>
	<td class="quantity">{{Line.unitQuantity}}</td>
	<td class="amount">{% if not parameters.gift_receipt %}{{Line.calcSubtotal|money}}{% endif %}</td>
</tr>
{% endmacro %}

{% macro receipt(Sale,parameters,show_lines,store_copy) %}
{% if Sale.SaleLines %}
	{% if show_lines %}
		<table class="sale lines">
			<thead>
				<tr>
					<th>Item</th>
					<th class="quantity">Qty.</th>
					<th class="amount">Price</th>
				</tr>
			</thead>
			<tbody>
				{% for Line in Sale.SaleLines.SaleLine %}
					{{ _self.line(Line,parameters) }}
				{% endfor %}
			</tbody>
		</table>

		{% if not parameters.gift_receipt %}
			<table class="totals">
				<tbody>
			  		<tr><td width="100%">Subtotal</td><td class="amount">{{Sale.calcSubtotal|money}}</td></tr>
			  		{% if Sale.calcDiscount > 0 %}
			  			<tr><td>Discounts</td><td class="amount">-{{Sale.calcDiscount|money}}</td></tr>
			  		{% elseif Sale.calcDiscount < 0 %}
						<tr><td>Discounts</td><td class="amount">{{Sale.calcDiscount|getinverse|money}}</td></tr>
			  		{% endif %}
					{% for Tax in Sale.TaxClassTotals.Tax %}
						{% if Tax.taxname %}
							<tr><td width="100%">{{Tax.taxname}} ({{Tax.taxable|money}} @ {{Tax.rate}}%)</td><td class="amount">{{Tax.amount|money}}</td></tr>
						{% endif %}
						{% if Tax.taxname2 and Tax.rate2 > 0 %}
							<tr><td width="100%">{{Tax.taxname2}} ({{Tax.taxable|money}} @ {{Tax.rate2}}%)</td><td class="amount">{{Tax.amount2|money}}</td></tr>
						{% endif %}
					{% endfor %}
			        <tr><td width="100%">Total Tax</td><td class="amount">{{Sale.taxTotal|money}}</td></tr>
					<tr class="total"><td>Total</td><td class="amount">{{Sale.calcTotal|money}}</td></tr>
				</tbody>
			</table>
		{% endif %}
	{% endif %}
{% endif %}

{% if Sale.completed == 'true' and not parameters.gift_receipt %}
	{% if Sale.SalePayments %}
		<h2>Payments</h2>
		<table class="payments">
			<tbody>
			{% for Payment in Sale.SalePayments.SalePayment %}
				{% if Payment.PaymentType.name != 'Cash' and Payment.archived == 'false' %}
					<!-- NOT Cash Payment -->
					{% if Payment.CreditAccount.giftCard == 'true' %}
						<!--  Gift Card -->
						{% if Payment.amount > 0 %}
							<tr>
								<td>Gift Card Charge</td>
								<td class="amount">{{Payment.amount|money}}</td>
							</tr>
							<tr>
								<td>Balance</td>
								<td class="amount">{{Payment.CreditAccount.balance|getinverse|money}}</td>
							</tr>
						{% elseif Payment.amount < 0 and Sale.calcTotal < 0 %}
							<tr>
								<td>Refund To Gift Card</td>
								<td class="amount">{{Payment.amount|getinverse|money}}</td>
							</tr>
							<tr>
								<td>Balance</td>
								<td class="amount">{{Payment.CreditAccount.balance|getinverse|money}}
							</tr>
						{% elseif Payment.amount < 0 and Sale.calcTotal >= 0 %}
							<tr>
								<td>Gift Card Purchase</td>
								<td class="amount">{{Payment.amount|getinverse|money}}</td>
							</tr>
							<tr>
								<td>Balance</td>
								<td class="amount">{{Payment.CreditAccount.balance|getinverse|money}}</td>
							</tr>
						{% endif %}
					{% elseif Payment.creditAccountID == 0 %}
						<!--  NOT Customer Account -->
						{{ _self.cc_payment_info(Sale,Payment) }}
					{% elseif Payment.CreditAccount %}
						<!-- Customer Account -->
						<tr>
						    {% if Payment.amount < 0 %}
							<td>Account Deposit</td>
							<td class="amount">{{Payment.amount|getinverse|money}}</td>
						    {% else %}
							<td>Account Charge</td>
							<td class="amount">{{Payment.amount|money}}</td>
						    {% endif %}
						</tr>
					{% endif %}
				{% endif %}
			{% endfor %}
			<tr><td colspan="2"></td></tr>
			{{ _self.sale_cash_payment(Sale) }}
			</tbody>
		</table>
	{% endif %}
	
	{% if Sale.Customer and store_copy == false %}
		{{ _self.layaways(Sale.Customer,parameters.gift_receipt)}}
		{{ _self.specialorders(Sale.Customer,parameters.gift_receipt)}}
		{{ _self.workorders(Sale.Customer,parameters.gift_receipt)}}
	{% endif %}
	
	{% if Sale.Customer and not parameters.gift_receipt and store_copy == false %}
		{% if Sale.Customer.CreditAccount and Sale.Customer.CreditAccount.MetaData.creditBalanceOwed > 0 or Sale.Customer.CreditAccount.MetaData.extraDeposit > 0 %}
			<h2>Store Account</h2>
			<table class="totals">
				{% if Sale.Customer.CreditAccount.MetaData.creditBalanceOwed > 0 %}
					<tr>
						<td width="100%">Balance Owed: </td>
						<td class="amount">{{ Sale.Customer.CreditAccount.MetaData.creditBalanceOwed|money }}</td>
					</tr>
				{% elseif Sale.Customer.CreditAccount.MetaData.extraDeposit > 0 %}
					<tr>
						<td width="100%">On Deposit </td>
						<td class="amount">{{ Sale.Customer.CreditAccount.MetaData.extraDeposit|money }}</td>
					</tr>
				{% endif %}
			</table>
		{% endif %}
		{% if Sale.Customer.MetaData.getAmountToCompleteAll > 0 %}
		<table class="totals">
			<tr class="total">
				<td width="100%">Remaining Balance </td>
				<td class="amount">{{ Sale.Customer.MetaData.getAmountToCompleteAll|money }}</td>
			</tr>
		</table>
		{% endif %}
	{% endif %}

{% endif %}
{% endmacro %}

{% macro cc_payment_info(Sale,Payment) %}
<tr>
	<td width="100%">
	{{ Payment.PaymentType.name }}
		{% if Payment.ccChargeID > 0 %}
			<br>Card Num: {{Payment.CCCharge.xnum}}
			{% if Payment.CCCharge.cardType|strlen > 0 %}
				<br>Type: {%if Payment.CCCharge.isDebit %}Debit/{% endif %}{{Payment.CCCharge.cardType}}
			{% endif %}
			{% if Payment.CCCharge.cardholderName|strlen > 0 %}
				<br>Cardholder: {{Payment.CCCharge.cardholderName}}
			{% endif %}
			{% if Payment.CCCharge.entryMethod|strlen > 0 %}
				<br>Entry: {{Payment.CCCharge.entryMethod}}
			{% endif %}
			{% if Payment.CCCharge.authCode|strlen > 0 %}
				<br>Approval: {{Payment.CCCharge.authCode}}
			{% endif %}
			{% if Payment.CCCharge.gatewayTransID|strlen > 0 and Payment.CCCharge.gatewayTransID|strlen < 48 %}
				<br>ID: {{Payment.CCCharge.gatewayTransID}}
			{% endif %}
		{% endif %}
	</td>
	<td class="amount">{{Payment.amount|money}}</td>
</tr>
{% endmacro %}


{% macro cc_agreement(Sale,Payment) %}
{% if Payment.CCCharge %}
	{% if Sale.Shop.ReceiptSetup.creditcardAgree|strlen > 0 %}
		<p>{{Sale.Shop.ReceiptSetup.creditcardAgree|noteformat|raw}}</p>
	{% endif %}
	<dl class="signature">
		<dt>Signature:</dt>
		<dd>
			{{Payment.CCCharge.cardholderName}}<br />
		</dd>
	</dl>
{% endif %}
{% endmacro %}

{% macro workorder_agreement(Sale) %}
	{% if Sale.Shop.ReceiptSetup.workorderAgree|strlen > 0 and Sale.Workorders %}
	<!-- 
		@FIXME
		Should only print this work_order agreement if it's never been signed before.
		transaction->customer_id->printWorkorderAgreement($transaction->transaction_id)  -->	
        <div class="signature">
        	<p>{{Sale.Shop.ReceiptSetup.workorderAgree|noteformat|raw}}</p>
        	<dl class="signature">
        		<dt>Signature:</dt>
        		<dd>{{Sale.Customer.firstName}} {{Sale.Customer.lastName}}</dd>
        	</dl>
        </div>
	{% endif %}
{% endmacro %}

{% macro ship_to(Sale) %}
	{% if Sale.ShipTo %}
	<div class="shipping">
		<h4>Ship To</h4>
		{{ _self.shipping_address(Sale.ShipTo,Sale.ShipTo.Contact) }}
		
		{% for Phone in Sale.ShipTo.Contact.Phones.ContactPhone %}{% if loop.first %}
		<p>Phone: {{Phone.number}} ({{Phone.useType}})</p>
		{% endif %}{% endfor %}
		
		{% if Sale.ShipTo.shipNote|strlen > 0 %}
		<h5>Instructions</h5>
		<p>{{Sale.ShipTo.shipNote}}</p>
		{% endif %}
	</div>
	{% endif %}
{% endmacro %}

{% macro shipping_address(Customer,Contact) %}
<p>
	{% if Customer.company|strlen > 0 %}{{Customer.company}}<br>{% endif %}
	{% if Customer.company|strlen > 0 %}Attn:{% endif %} {{Customer.firstName}} {{Customer.lastName}}<br>
	{{ _self.address(Contact) }}
</p>
{% endmacro %}

{% macro address(Contact,delimiter) %}
	{% if delimiter|strlen == 0 %}{% set delimiter = '<br>' %}{% endif %}

	{% autoescape false %}
	{% for Address in Contact.Addresses.ContactAddress %}
		{% if loop.first and Address.address1 %}
			{{Address.address1}}{{delimiter}}
			{% if Address.address2|strlen > 0 %} {{Address.address2}}{{delimiter}}{% endif %}
			{{Address.city}}, {{Address.state}} {{Address.zip}} {{Address.country}}
		{% endif %}
	{% endfor %}
	{% endautoescape %}
{% endmacro %}

{% macro layaways(Customer,parameters) %}
	{% if Customer.Layaways and Customer.Layaways|length > 0 %}
		<h2>Layaways</h2>
		<table class="lines layaways">
			<tbody>
				{% for Line in Customer.Layaways.SaleLine %}{{ _self.line(Line,parameters)}}{% endfor %}
			</tbody>
		</table>
		<table class="layways totals">
			<tr>
				<td width="100%">Subtotal</td>
				<td class="amount">{{Customer.MetaData.layawaysSubtotalNoDiscount|money}}</td>
			</tr>
			{% if Customer.MetaData.layawaysAllDiscounts>0.00 %}
				<tr>
					<td width="100%">Discounts</td>
					<td class="amount">{{Customer.MetaData.layawaysAllDiscounts|money}}</td>
				</tr>
			{% endif %}
			<tr>
				<td width="100%">Tax</td>
				<td class="amount">{{Customer.MetaData.layawaysTaxTotal|money}}</td>
			</tr>
			<tr class="total">
				<td width="100%">Total</td>
				<td class="amount">{{Customer.MetaData.layawaysTotal|money}}</td>
			</tr>
		</table>
	{% endif %}
{% endmacro %}

{% macro specialorders(Customer,parameters) %}
	{% if Customer.SpecialOrders|length > 0 %}
		<h2>Special Orders</h2>
		<table class="lines specialorders">
			<tbody>
				{% for Line in Customer.SpecialOrders.SaleLine %}{{ _self.line(Line,parameters) }}{% endfor %}
			</tbody>
		</table>
		<table class="specialorders totals">
			<tr>
				<td width="100%">Subtotal</td>
				<td class="amount">{{Customer.MetaData.specialOrdersSubtotalNoDiscount|money}}</td>
			</tr>
			{% if Customer.MetaData.specialOrdersAllDiscounts > 0 %}
				<tr>
					<td width="100%">Discounts</td>
					<td class="amount">{{Customer.MetaData.specialOrdersAllDiscounts|money}}</td>
				</tr>
			{% endif %}
			<tr>
				<td width="100%">Tax</td>
				<td class="amount">{{Customer.MetaData.specialOrdersTaxTotal|money}}</td>
			</tr>
			<tr class="total">
				<td width="100%">Total</td>
				<td class="amount">{{Customer.MetaData.specialOrdersTotal|money}}</td>
			</tr>
		</table>
	{% endif %}
{% endmacro %}

{% macro workorders(Customer,parameters) %}
	{% if Customer.Workorders|length > 0 %}
		<h2>Open Workorders</h2>
		<table class="lines workorders">
			{% for Line in Customer.Workorders.SaleLine %}
				<tr>
					{% if Line.MetaData.workorderTotal %}
						<td class="workorder" colspan="2">{{ _self.lineDescription(Line) }}</td>
					{% else %}
						<td >{{ _self.lineDescription(Line) }}</td>
						<td class="amount">{{Line.calcSubtotal|money}}</td>
					{% endif %}
				</tr>
			{% endfor %}
		</table>
		{% if Customer.MetaData.workordersTotal > 0 %}
			<table class="workorders totals">
				<tr>
					<td width="100%">Subtotal</td>
					<td class="amount">{{Customer.MetaData.workordersSubtotalNoDiscount|money}}</td>
				</tr>
				{% if Customer.MetaData.specialOrdersAllDiscounts > 0 %}
					<tr>
						<td width="100%">Discounts</td>
						<td class="amount">{{Customer.MetaData.workordersAllDiscounts|money}}</td>
					</tr>
				{% endif %}
				<tr>
					<td width="100%">Tax</td>
					<td class="amount">{{Customer.MetaData.workordersTaxTotal|money}}</td>
				</tr>
				<tr class="total">
					<td width="100%">Total</td>
					<td class="amount">{{Customer.MetaData.workordersTotal|money}}</td>
				</tr>
			</table>
		{% endif %}
	{% endif %}
{% endmacro %}

{% macro sale_cash_payment(Sale) %}
	{% set total = Sale.change|floatval %}
	{% set pay_cash = 'false' %}
	{% for Payment in Sale.SalePayments.SalePayment %}
		{% if Payment.PaymentType.name == 'Cash' %}
			{% set total = total + Payment.amount|floatval %}
			{% set pay_cash = 'true' %}
    		{% endif %}
	{% endfor %}
	{% if pay_cash == 'true' %}
		<tr><td width="100%">Cash</td><td class="amount">{{total|money}}</td></tr>
		<tr><td width="100%">Change</td><td class="amount">{{Sale.change|money}}</td></tr>
	{% endif %}
{% endmacro %}
