/* test selectors, for libreswan
 *
 * Copyright (C) 2000  Henry Spencer.
 * Copyright (C) 2018, 2019, 2020  Andrew Cagney
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.  See <https://www.gnu.org/licenses/lgpl-2.1.txt>.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public
 * License for more details.
 */

#include <stdio.h>

#include "lswcdefs.h"		/* for elemsof() */
#include "constants.h"		/* for streq() */
#include "ipcheck.h"
#include "ip_selector.h"	/* should be in ip_selector_check.c */

struct selector {
	int family;
	const char *addresses;
	const char *protoport;
};

struct from_test {
	int line;
	struct selector from;
	const char *subnet;
	const char *range;
	unsigned ipproto;
	uint16_t hport;
	uint8_t nport[2];
};

static void check_selector_from(const struct from_test *tests, unsigned nr_tests,
				const char *what,
				err_t (*to_selector)(const struct selector *from,
						     ip_selector *out, struct logger *logger),
				struct logger *logger)
{

	for (size_t ti = 0; ti < nr_tests; ti++) {
		const struct from_test *t = &tests[ti];
		PRINT("%s %s=%s protoport=%s range=%s ipproto=%u hport=%u nport=%02x%02x",
		      pri_family(t->from.family),
		      what, t->from.addresses != NULL ? t->from.addresses : "N/A",
		      t->from.protoport != NULL ? t->from.protoport : "N/A",
		      t->range != NULL ? t->range : "N/A",
		      t->ipproto,
		      t->hport,
		      t->nport[0], t->nport[1]);

		ip_selector tmp, *selector = &tmp;
		err_t err = to_selector(&t->from, selector, logger);
		if (t->range != NULL) {
			if (err != NULL) {
				FAIL("to_selector() failed: %s", err);
			}
		} else if (err == NULL) {
			FAIL("to_selector() should have failed");
		} else {
			continue;
		}

		CHECK_FAMILY(t->from.family, selector, selector);

		ip_subnet subnet = selector_subnet(*selector);
		subnet_buf sb;
		str_subnet(&subnet, &sb);
		if (!streq(sb.buf, t->subnet)) {
			FAIL("str_range() was %s, expected %s", sb.buf, t->subnet);
		}

		ip_range range = selector_range(*selector);
		range_buf rb;
		str_range(&range, &rb);
		if (!streq(rb.buf, t->range)) {
			FAIL("range was %s, expected %s", rb.buf, t->range);
		}

		const ip_protocol *protocol = selector_protocol(*selector);
		if (protocol->ipproto != t->ipproto) {
			FAIL("ipproto was %u, expected %u", protocol->ipproto, t->ipproto);
		}

		ip_port port = selector_port(*selector);

		uint16_t hp = hport(port);
		if (!memeq(&hp, &t->hport, sizeof(hport))) {
			FAIL("selector_hport() returned '%d', expected '%d'",
			     hp, t->hport);
		}

		uint16_t np = nport(port);
		if (!memeq(&np, &t->nport, sizeof(nport))) {
			FAIL("selector_nport() returned '%04x', expected '%02x%02x'",
			     np, t->nport[0], t->nport[1]);
		}
	}
}

static err_t do_selector_from_address(const struct selector *s,
				      ip_selector *selector,
				      struct logger *logger_unused UNUSED)
{
	if (s->family == 0) {
		*selector = unset_selector;
		return NULL;
	}

	ip_address address;
	err_t err = ttoaddress_num(shunk1(s->addresses), IP_TYPE(s->family), &address);
	if (err != NULL) {
		return err;
	}

	ip_protoport protoport;
	err = ttoprotoport(s->protoport, &protoport);
	if (err != NULL) {
		return err;
	}

	*selector = selector_from_address_protoport(address, protoport);
	return NULL;
}

static void check_selector_from_address(struct logger *logger)
{
	static const struct from_test tests[] = {
		{ LN, { 4, "128.0.0.0", "0/0", }, "128.0.0.0/32", "128.0.0.0-128.0.0.0", 0, 0, { 0, 0, }, },
		{ LN, { 6, "8000::", "16/10", }, "8000::/128", "8000::-8000::", 16, 10, { 0, 10, }, },
	};
	check_selector_from(tests, elemsof(tests), "address",
			    do_selector_from_address, logger);
}

static err_t do_selector_from_subnet_protoport(const struct selector *s,
					       ip_selector *selector,
					       struct logger *logger)
{
	if (s->family == 0) {
		*selector = unset_selector;
		return NULL;
	}

	ip_subnet subnet;
	err_t err = ttosubnet(shunk1(s->addresses), IP_TYPE(s->family), '6',
			      &subnet, logger);
	if (err != NULL) {
		return err;
	}

	ip_protoport protoport;
	err = ttoprotoport(s->protoport, &protoport);
	if (err != NULL) {
		return err;
	}

	*selector = selector_from_subnet_protoport(subnet, protoport);
	return NULL;
}

static void check_selector_from_subnet_protoport(struct logger *logger)
{
	static const struct from_test tests[] = {
		/* zero port implied */
		{ LN, { 4, "0.0.0.0/0", "0/0", }, "0.0.0.0/0", "0.0.0.0-255.255.255.255", 0, 0, { 0, 0, }, },
		{ LN, { 6, "::0/0", "0/0", }, "::/0", "::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", 0, 0, { 0, 0, }, },
		{ LN, { 4, "101.102.0.0/16", "0/0", }, "101.102.0.0/16", "101.102.0.0-101.102.255.255", 0, 0, { 0, 0, }, },
		{ LN, { 6, "1001:1002:1003:1004::/64", "0/0", }, "1001:1002:1003:1004::/64", "1001:1002:1003:1004::-1001:1002:1003:1004:ffff:ffff:ffff:ffff", 0, 0, { 0, 0, }, },
		{ LN, { 4, "101.102.103.104/32", "0/0", }, "101.102.103.104/32", "101.102.103.104-101.102.103.104", 0, 0, { 0, 0, }, },
		{ LN, { 6, "1001:1002:1003:1004:1005:1006:1007:1008/128", "0/0", }, "1001:1002:1003:1004:1005:1006:1007:1008/128", "1001:1002:1003:1004:1005:1006:1007:1008-1001:1002:1003:1004:1005:1006:1007:1008", 0, 0, { 0, 0, }, },
		/* "reserved" zero port specified; reject? */
		{ LN, { 4, "0.0.0.0/0", "0/0", }, "0.0.0.0/0", "0.0.0.0-255.255.255.255", 0, 0, { 0, 0, }, },
		{ LN, { 6, "::0/0", "0/0", }, "::/0", "::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", 0, 0, { 0, 0, }, },
		{ LN, { 4, "101.102.0.0/16", "0/0", }, "101.102.0.0/16", "101.102.0.0-101.102.255.255", 0, 0, { 0, 0, }, },
		{ LN, { 6, "1001:1002:1003:1004::/64", "0/0", }, "1001:1002:1003:1004::/64", "1001:1002:1003:1004::-1001:1002:1003:1004:ffff:ffff:ffff:ffff", 0, 0, { 0, 0, }, },
		{ LN, { 4, "101.102.103.104/32", "0/0", }, "101.102.103.104/32", "101.102.103.104-101.102.103.104", 0, 0, { 0, 0, }, },
		{ LN, { 6, "1001:1002:1003:1004:1005:1006:1007:1008/128", "0/0", }, "1001:1002:1003:1004:1005:1006:1007:1008/128", "1001:1002:1003:1004:1005:1006:1007:1008-1001:1002:1003:1004:1005:1006:1007:1008", 0, 0, { 0, 0, }, },
		/* non-zero port mixed with mask; only allow when /32/128? */
		{ LN, { 4, "0.0.0.0/0", "16/65534", }, "0.0.0.0/0", "0.0.0.0-255.255.255.255", 16, 65534, { 255, 254, }, },
		{ LN, { 6, "::0/0", "16/65534", }, "::/0", "::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", 16, 65534, { 255, 254, }, },
		{ LN, { 4, "101.102.0.0/16", "16/65534", }, "101.102.0.0/16", "101.102.0.0-101.102.255.255", 16, 65534, { 255, 254, }, },
		{ LN, { 6, "1001:1002:1003:1004::/64", "16/65534", }, "1001:1002:1003:1004::/64", "1001:1002:1003:1004::-1001:1002:1003:1004:ffff:ffff:ffff:ffff", 16, 65534, { 255, 254, }, },
		{ LN, { 4, "101.102.103.104/32", "16/65534", }, "101.102.103.104/32", "101.102.103.104-101.102.103.104", 16, 65534, { 255, 254, }, },
		{ LN, { 6, "1001:1002:1003:1004:1005:1006:1007:1008/128", "16/65534", }, "1001:1002:1003:1004:1005:1006:1007:1008/128", "1001:1002:1003:1004:1005:1006:1007:1008-1001:1002:1003:1004:1005:1006:1007:1008", 16, 65534, { 255, 254, }, },
	};
	check_selector_from(tests, elemsof(tests), "subnet",
			    do_selector_from_subnet_protoport, logger);
}

static err_t do_numeric_to_selector(const struct selector *s,
				    ip_selector *selector,
				    struct logger *logger_ UNUSED)
{
	if (s->family == 0) {
		*selector = unset_selector;
		return NULL;
	}

	return numeric_to_selector(shunk1(s->addresses), IP_TYPE(s->family), selector);
}

static void check_numeric_to_selector(struct logger *logger)
{
	static const struct from_test tests[] = {
		/* missing prefix-bits */
		{ LN, { 4, "0.0.0.0", NULL, }, "0.0.0.0/32", "0.0.0.0-0.0.0.0", 0, 0, { 0, 0, }, },
		{ LN, { 6, "::0", NULL, }, "::/128", "::-::", 0, 0, { 0, 0, }, },
		/* missing protocol/port */
		{ LN, { 4, "0.0.0.0/0", NULL, }, "0.0.0.0/0", "0.0.0.0-255.255.255.255", 0, 0, { 0, 0, }, },
		{ LN, { 6, "::0/0", NULL, }, "::/0", "::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", 0, 0, { 0, 0, }, },
		{ LN, { 4, "101.102.0.0/16", NULL, }, "101.102.0.0/16", "101.102.0.0-101.102.255.255", 0, 0, { 0, 0, }, },
		{ LN, { 6, "1001:1002:1003:1004::/64", NULL, }, "1001:1002:1003:1004::/64", "1001:1002:1003:1004::-1001:1002:1003:1004:ffff:ffff:ffff:ffff", 0, 0, { 0, 0, }, },
		{ LN, { 4, "101.102.103.104/32", NULL, }, "101.102.103.104/32", "101.102.103.104-101.102.103.104", 0, 0, { 0, 0, }, },
		{ LN, { 6, "1001:1002:1003:1004:1005:1006:1007:1008/128", NULL, }, "1001:1002:1003:1004:1005:1006:1007:1008/128", "1001:1002:1003:1004:1005:1006:1007:1008-1001:1002:1003:1004:1005:1006:1007:1008", 0, 0, { 0, 0, }, },
		/* "reserved" zero port specified; reject? */
		{ LN, { 4, "0.0.0.0/0:0/0", NULL, }, "0.0.0.0/0", "0.0.0.0-255.255.255.255", 0, 0, { 0, 0, }, },
		{ LN, { 6, "::0/0:0/0", NULL, }, "::/0", "::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", 0, 0, { 0, 0, }, },
		{ LN, { 4, "101.102.0.0/16:0/0", NULL, }, "101.102.0.0/16", "101.102.0.0-101.102.255.255", 0, 0, { 0, 0, }, },
		{ LN, { 6, "1001:1002:1003:1004::/64:0/0", NULL, }, "1001:1002:1003:1004::/64", "1001:1002:1003:1004::-1001:1002:1003:1004:ffff:ffff:ffff:ffff", 0, 0, { 0, 0, }, },
		{ LN, { 4, "101.102.103.104/32:0/0", NULL, }, "101.102.103.104/32", "101.102.103.104-101.102.103.104", 0, 0, { 0, 0, }, },
		{ LN, { 6, "1001:1002:1003:1004:1005:1006:1007:1008/128:0/0", NULL, }, "1001:1002:1003:1004:1005:1006:1007:1008/128", "1001:1002:1003:1004:1005:1006:1007:1008-1001:1002:1003:1004:1005:1006:1007:1008", 0, 0, { 0, 0, }, },
		/* non-zero port mixed with mask; only allow when /32/128? */
		{ LN, { 4, "0.0.0.0/0:udp/65534", NULL, }, "0.0.0.0/0", "0.0.0.0-255.255.255.255", 17, 65534, { 255, 254, }, },
		{ LN, { 6, "::0/0:udp/65534", NULL, }, "::/0", "::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", 17, 65534, { 255, 254, }, },
		{ LN, { 4, "101.102.0.0/16:udp/65534", NULL, }, "101.102.0.0/16", "101.102.0.0-101.102.255.255", 17, 65534, { 255, 254, }, },
		{ LN, { 6, "1001:1002:1003:1004::/64:udp/65534", NULL, }, "1001:1002:1003:1004::/64", "1001:1002:1003:1004::-1001:1002:1003:1004:ffff:ffff:ffff:ffff", 17, 65534, { 255, 254, }, },
		{ LN, { 4, "101.102.103.104/32:udp/65534", NULL, }, "101.102.103.104/32", "101.102.103.104-101.102.103.104", 17, 65534, { 255, 254, }, },
		{ LN, { 6, "1001:1002:1003:1004:1005:1006:1007:1008/128:udp/65534", NULL, }, "1001:1002:1003:1004:1005:1006:1007:1008/128", "1001:1002:1003:1004:1005:1006:1007:1008-1001:1002:1003:1004:1005:1006:1007:1008", 17, 65534, { 255, 254, }, },
		/* hex/octal */
		{ LN, { 4, "101.102.0.0/16:tcp/0xfffe", NULL, }, "101.102.0.0/16", "101.102.0.0-101.102.255.255", 6, 65534, { 255, 254, }, },
		{ LN, { 6, "1001:1002:1003:1004::/64:udp/0177776", NULL, }, "1001:1002:1003:1004::/64", "1001:1002:1003:1004::-1001:1002:1003:1004:ffff:ffff:ffff:ffff", 17, 65534, { 255, 254, }, },
		/* invalid */
		{ LN, { 4, "1.2.3.4/", NULL, }, NULL, NULL, 0, 0, { 0, 0, }, },
		{ LN, { 4, "1.2.3.4/24", NULL, }, NULL, NULL, 0, 0, { 0, 0, }, },
		{ LN, { 4, "1.2.3.0/24:", NULL, }, NULL, NULL, 0, 0, { 0, 0, }, },
		{ LN, { 4, "1.2.3.0/24:-1/-1", NULL, }, NULL, NULL, 0, 0, { 0, 0, }, },
		{ LN, { 4, "1.2.3.0/24:none/", NULL, }, NULL, NULL, 0, 0, { 0, 0, }, },
	};

	check_selector_from(tests, elemsof(tests), "selector",
			    do_numeric_to_selector, logger);
}

static void check_selector_is(struct logger *logger)
{
	static const struct test {
		int line;
		struct selector from;
		bool is_unset;
		bool is_zero;
		bool is_all;
		bool contains_one_address;
	} tests[] = {
		/* all */
		{ LN, { 0, NULL, NULL, },            .is_unset = true, },
		/* all */
		{ LN, { 4, "0.0.0.0/0", "0/0", },    .is_all = true, },
		{ LN, { 6, "::/0", "0/0", },         .is_all = true, },
		/* some */
		{ LN, { 4, "127.0.0.0/31", "0/0", }, .is_unset = false, },
		{ LN, { 6, "8000::/127", "0/0", },   .is_unset = false, },
		/* one */
		{ LN, { 4, "127.0.0.1/32", "0/0", }, .contains_one_address = true, },
		{ LN, { 6, "8000::/128", "0/0", },   .contains_one_address = true, },
		/* none */
		{ LN, { 4, "0.0.0.0/32", "0/0", },   .is_zero = true, },
		{ LN, { 6, "::/128", "0/0", },       .is_zero = true, },
	};

	for (size_t ti = 0; ti < elemsof(tests); ti++) {
		err_t err;
		const struct test *t = &tests[ti];
		PRINT("%s subnet=%s protoport=%s unset=%s zero=%s all=%s one=%s",
		      pri_family(t->from.family),
		      t->from.addresses != NULL ? t->from.addresses : "<unset>",
		      t->from.protoport != NULL ? t->from.protoport : "<unset>",
		      bool_str(t->is_unset),
		      bool_str(t->is_zero),
		      bool_str(t->is_all),
		      bool_str(t->contains_one_address));

		ip_selector tmp, *selector = &tmp;
		err = do_numeric_to_selector(&t->from, selector, logger);
		if (err != NULL) {
			FAIL("to_selector() failed: %s", err);
		}

		CHECK_COND(selector, is_unset);
		CHECK_COND2(selector, is_zero);
		CHECK_COND2(selector, is_all);
		CHECK_COND2(selector, contains_one_address);
	}
}

static void check_selector_op_selector(void)
{

	static const struct test {
		int line;
		const char *inner;
		const char *outer;
		bool selector;
		bool address;
		bool endpoint;
	} tests[] = {

		/*
		 * all - remember LHS needs a non-zero address
		 */

		{ LN, "0.0.0.0/0:0/0", "0.0.0.0/0:0/0",        true,  true,  false, },
		{ LN, "::/0:0/0",      "::/0:0/0",             true,  true,  false, },

		{ LN, "0.0.0.0/0:0/0", "0.0.0.0/0:udp/10",     false, true,  false, },
		{ LN, "::/0:0/0", "::/0:udp/10",               false, true,  false, },

		{ LN, "0.0.0.0/0:udp/10", "0.0.0.0/0:0/0",     true,  true,  true, },
		{ LN, "::/0:udp/10",      "::/0:0/0",          true,  true,  true, },

		{ LN, "0.0.0.0/0:udp/10", "0.0.0.0/0:udp/10",  true,  true,  true, },
		{ LN, "::/0:udp/10",      "::/0:udp/10",       true,  true,  true, },

		{ LN, "0.0.0.0/0:udp/10", "0.0.0.0/0:udp/11",  false, true,  false, },
		{ LN, "::/0:udp/10",      "::/0:udp/11",       false, true,  false, },

		{ LN, "0.0.0.0/0:udp/10", "0.0.0.0/0:tcp/10",  false, true,  false, },
		{ LN, "::/0:udp/10",      "::/0:tcp/10",       false, true,  false, },

		/* some */

		{ LN, "127.0.0.1/32:0/0", "127.0.0.0/31:0/0",     true,true, true, },
		{ LN, "8000::/128:0/0", "8000::/127:0/0",         true, true, true, },

		{ LN, "127.0.0.1/32:0/0", "127.0.0.0/31:tcp/10",  false, true, false, },
		{ LN, "8000::/128:0/0", "8000::/127:tcp/10",      false, true, false, },

		{ LN, "127.0.0.1/32:tcp/10", "127.0.0.0/31:0/0",  true, true, true, },
		{ LN, "8000::/128:tcp/10", "8000::/127:0/0",      true, true, true, },

		{ LN, "127.0.0.1/32:tcp/10", "127.0.0.0/31:tcp/10", true, true, true, },
		{ LN, "8000::/128:tcp/10", "8000::/127:tcp/10",   true, true, true, },

		{ LN, "127.0.0.1/32:tcp/10", "127.0.0.0/31:tcp/11", false, true, false, },
		{ LN, "8000::/128:tcp/10", "8000::/127:tcp/11",   false, true, false, },

		{ LN, "127.0.0.1/32:tcp/10", "127.0.0.0/31:udp/10", false, true, false, },
		{ LN, "8000::/128:tcp/10", "8000::/127:udp/10",   false, true, false, },

		/* one */

		{ LN, "127.0.0.1/32:0/0", "127.0.0.1/32:0/0",       true, true, true, },
		{ LN, "8000::/128:0/0", "8000::/128:0/0",         true, true, true, },

		{ LN, "127.0.0.1/32:0/0", "127.0.0.1/32:udp/10",    false, true, false, },
		{ LN, "8000::/128:0/0", "8000::/128:udp/10",      false, true, false, },

		{ LN, "127.0.0.1/32:udp/10", "127.0.0.1/32:0/0",    true, true, true, },
		{ LN, "8000::/128:udp/10", "8000::/128:0/0",      true, true, true, },

		{ LN, "127.0.0.1/32:udp/10", "127.0.0.1/32:udp/10", true, true, true, },
		{ LN, "8000::/128:udp/10", "8000::/128:udp/10",   true, true, true, },

		{ LN, "127.0.0.1/32:udp/10", "127.0.0.1/32:udp/11", false, true, false, },
		{ LN, "8000::/128:udp/10", "8000::/128:udp/11",   false, true, false, },

		{ LN, "127.0.0.1/32:udp/10", "127.0.0.1/32:tcp/10", false, true, false, },
		{ LN, "8000::/128:udp/10", "8000::/128:tcp/10",   false, true, false, },

		/* allow ::/N:udp/10 provided it isn't ::/128 */

		{ LN, "127.0.0.0/32:0/0", "0.0.0.0/31:0/0",    false, false, false, },
		{ LN, "::1/128:0/0", "::/127:0/0",             true,  true,  true, },

		{ LN, "127.0.0.0/32:udp/10", "0.0.0.0/31:udp/10",   false, false, false, },
		{ LN, "::1/128:udp/10", "::/127:udp/10",       true,  true,  true, },

		/* these a non-sensical - rhs has no addresses yet udp */

		{ LN, "127.0.0.0/32:0/0", "0.0.0.0/32:udp/10", false, false, false, },
		{ LN, "::1/128:0/0", "::/128:udp/10",          false, false, false, },

		{ LN, "127.0.0.0/32:udp/10", "0.0.0.0/32:udp/10",   false, false, false, },
		{ LN, "::1/128:udp/10", "::/128:udp/10",       false, false, false, },

		/* zero - can match self */

		{ LN, "127.0.0.0/32:0/0", "0.0.0.0/32:0/0",    false, false, false, },
		{ LN, "::1/128:0/0",      "::/128:0/0",        false, false, false, },

		{ LN, "127.0.0.0/32:udp/10", "0.0.0.0/32:0/0", false, false, false, },
		{ LN, "::1/128:udp/10",      "::/128:0/0",     false, false, false, },

		{ LN, "0.0.0.0/32:0/0", "0.0.0.0/32:0/0",      true,  true,  false, },
		{ LN, "::/128:0/0",     "::/128:0/0",          true,  true,  false, },

		{ LN, "0.0.0.0/32:udp/10", "0.0.0.0/32:0/0",   true,  true,  true, },
		{ LN, "::/128:udp/10", "::/128:0/0",           true,  true,  true, },

	};

	for (size_t ti = 0; ti < elemsof(tests); ti++) {
		err_t err;
		const struct test *t = &tests[ti];
		PRINT("%s in %s: selector=%s address=%s endpoint=%s",
		      t->inner, t->outer,
		      bool_str(t->selector),
		      bool_str(t->address),
		      bool_str(t->endpoint));

		ip_selector inner_selector;
		err = numeric_to_selector(shunk1(t->inner), NULL, &inner_selector);
		if (err != NULL) {
			FAIL("numeric_to_selector(%s) failed: %s", t->inner, err);
		}

		ip_selector outer_selector;
		err = numeric_to_selector(shunk1(t->outer), NULL, &outer_selector);
		if (err != NULL) {
			FAIL("numeric_to_selector(%s) failed: %s", t->outer, err);
		}

		bool selector = selector_in_selector(inner_selector, outer_selector);
		if (selector != t->selector) {
			selector_buf si, so;
			FAIL("selector_in_selector(%s, %s) returned %s, expecting %s",
			     str_selector(&inner_selector, &si),
			     str_selector(&outer_selector, &so),
			     bool_str(selector), bool_str(t->selector));
		}

		ip_address inner_address = selector_prefix(inner_selector);
		bool address = address_in_selector_subnet(inner_address, outer_selector);
		if (address != t->address) {
			address_buf ab;
			selector_buf sb;
			FAIL("address_in_selector_subnet(%s, %s) returned %s, expecting %s",
			     str_address(&inner_address, &ab),
			     str_selector(&outer_selector, &sb),
			     bool_str(address), bool_str(t->address));
		}

		const ip_protocol *protocol = selector_protocol(inner_selector);
		ip_port port = selector_port(inner_selector);
		if (protocol != &ip_protocol_unset && port.hport != 0) {
			ip_endpoint inner_endpoint = endpoint_from_address_protocol_port(inner_address,
											 protocol, port);
			bool endpoint = endpoint_in_selector(inner_endpoint, outer_selector);
			if (endpoint != t->endpoint) {
				endpoint_buf eb;
				selector_buf sb;
				FAIL("endpoint_in_selector(%s, %s) returned %s, expecting %s",
				     str_endpoint(&inner_endpoint, &eb),
				     str_selector(&outer_selector, &sb),
				     bool_str(endpoint), bool_str(t->endpoint));
			}
		}
	}
}

void ip_selector_check(struct logger *logger)
{
	check_selector_from_address(logger);
	check_selector_from_subnet_protoport(logger);
	check_selector_is(logger);
	check_numeric_to_selector(logger);
	check_selector_op_selector();
}
