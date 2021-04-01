/* ip endpoint (address + port), for libreswan
 *
 * Copyright (C) 2019-2020 Andrew Cagney <cagney@gnu.org>
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
 *
 */

#ifndef IP_ENDPOINT_H
#define IP_ENDPOINT_H

#include <stdbool.h>

#include "chunk.h"
#include "err.h"
#include "ip_address.h"
#include "ip_port.h"
#include "ip_protoport.h"
#include "ip_bytes.h"

struct jambuf;
struct ip_protocol;

typedef struct {
	bool is_set;
	/*
	 * Index into the struct ip_info array; must be stream
	 * friendly.
	 */
	enum ip_version version; /* 0, 4, 6 */
	/*
	 * We need something that makes static IPv4 initializers possible
	 * (struct in_addr requires htonl() which is run-time only).
	 */
	struct ip_bytes bytes;
	/*
	 * Protocol 0 is interpreted as a wild card so isn't allowed.
	 */
	unsigned ipproto;
	/*
	 * For protocols such as UDP and TCP, the 0 port is
	 * interpreted as a wild card so isn't allowed.
	 */
	int hport;
} ip_endpoint;

#define PRI_ENDPOINT "%s (is_set=%s version=%d bytes="PRI_BYTES" ipproto=%u hport=%u"
#define pri_endpoint(A, B)						\
	str_endpoint(A, B),						\
		bool_str((A)->is_set),					\
		(A)->version,						\
		pri_bytes((A)->bytes),					\
		(A)->ipproto,						\
		(A)->hport

void pexpect_endpoint(const ip_endpoint *e, where_t where);
#define pendpoint(E) pexpect_endpoint(E, HERE)

/*
 * Constructors.
 */

ip_endpoint endpoint_from_raw(where_t where, enum ip_version version,
			      const struct ip_bytes bytes,
			      const struct ip_protocol *protocol,
			      ip_port port);

ip_endpoint endpoint_from_address_protocol_port(const ip_address address,
						const struct ip_protocol *protocol,
						ip_port port);

/*
 * Formatting
 *
 * Endpoint formatting is always "cooked".  For instance, the address
 * "::1" is printed as "[::1]:PORT" (raw would print it as
 * "[0:0....:0]:PORT"
 *
 * XXX: sizeof("") includes '\0'.  What's an extra few bytes between
 * friends?
 */

typedef struct {
	char buf[sizeof("[") + sizeof(address_buf) + sizeof("]:65535")];
} endpoint_buf;

size_t jam_endpoint(struct jambuf *, const ip_endpoint*);
size_t jam_endpoint_sensitive(struct jambuf *, const ip_endpoint*);

const char *str_endpoint(const ip_endpoint *, endpoint_buf *);
const char *str_endpoint_sensitive(const ip_endpoint *, endpoint_buf *);

typedef struct {
	char buf[sizeof(endpoint_buf) + sizeof("--UNKNOWN--UNKNOWN-->") + sizeof(endpoint_buf)];
} endpoints_buf;

size_t jam_endpoints(struct jambuf *jambuf, const ip_endpoint *src, const ip_endpoint *dst);
const char *str_endpoints(const ip_endpoint *src, const ip_endpoint *dst, endpoints_buf *buf);

/*
 * Magic values.
 *
 * XXX: While the headers call the all-zero address "ANY" (INADDR_ANY,
 * IN6ADDR_ANY_INIT), the headers also refer to the IPv6 value as
 * unspecified (for instance IN6_IS_ADDR_UNSPECIFIED()) leaving the
 * term "unspecified" underspecified.
 *
 * Consequently an AF_UNSPEC address (i.e., uninitialized or unset),
 * is identified by *_unset().
 */

extern const ip_endpoint unset_endpoint;

bool endpoint_is_unset(const ip_endpoint *endpoint);			/* handles NULL */
const struct ip_info *endpoint_type(const ip_endpoint *endpoint);	/* handles NULL */

bool endpoint_is_specified(const ip_endpoint endpoint);

const struct ip_protocol *endpoint_protocol(const ip_endpoint endpoint);
ip_address endpoint_address(const ip_endpoint endpoint);
ip_port endpoint_port(const ip_endpoint endpoint);

/*
 * Logic
 */

bool endpoint_eq_endpoint(const ip_endpoint l, const ip_endpoint r);
bool endpoint_address_eq_address(const ip_endpoint endpoint, const ip_address address);

/*
 * hacks
 */

int endpoint_hport(const ip_endpoint endpoint);
ip_endpoint set_endpoint_port(const ip_endpoint endpoint,
			      ip_port port) MUST_USE_RESULT;
void update_endpoint_port(ip_endpoint *endpoint, ip_port port);

#endif
