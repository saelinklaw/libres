/*
 * conversion from protocol/port string to protocol and port
 *
 * Copyright (C) 2002 Mario Strasser <mast@gmx.net>,
 *                    Zuercher Hochschule Winterthur,
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.  See <https://www.gnu.org/licenses/gpl2.txt>.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for more details.
 */

#include "ipcheck.h"
#include "ip_protoport.h"

void ip_protoport_check(void)
{
	static const struct test {
		int line;
		char *in;
		unsigned ipproto;
		unsigned hport;
		bool ok;
	} tests[] = {
		/* { LN, "", 0, 0, false, }, */
		{ LN, "tcp/%any", 6, 0, true,  },
		{ LN, "udp/255", 17, 255, true,  },
		{ LN, "0/1", 0, 0, false,  },
		{ LN, "0/0", 0, 0, true,  },
		{ LN, "47", 47, 0, true, },
		{ LN, "47/", 47, 0, true, },
		{ LN, "something-longer-than-16-bytes/0", 0, 0, false, }
	};

	for (size_t ti = 0; ti < elemsof(tests); ti++) {
		const struct test *t = &tests[ti];
		PRINT("in=%s proto=%u port=%u ok=%s",
		      t->in, t->ipproto, t->hport, bool_str(t->ok));

		ip_protoport out;
		err_t err = ttoprotoport(t->in, &out);

		if (!t->ok && err == NULL) {
			FAIL("%s expected error, got none", t->in);
		}

		if (t->ok && err != NULL) {
			FAIL("%s got error: %s\n", t->in, err);
		}

		if (out.ipproto != t->ipproto) {
			FAIL("%s expected proto %u, got %u", t->in,
			     t->ipproto, out.ipproto);
		}

		if (out.hport != t->hport) {
			FAIL("%s expected port %u, got %u",
			     t->in, t->hport, out.hport);
		}
	}
}
