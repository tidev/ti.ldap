const LDAP = require('ti.ldap');

// Test server online: https://www.forumsys.com/tutorials/integration-how-to/ldap/online-ldap-test-server/

describe('ti.ldap', function () {
	it('#createConnection()', () => {
		const connection = LDAP.createConnection({});

		expect(connection).toEqual(jasmine.any(Object));
	});

	describe('Connection', () => {
		describe('.useTLS', () => {
			it('defaults to false', () => {
				const connection = LDAP.createConnection({});

				expect(connection.useTLS).toEqual(false);
			});
		});

		describe('.certFile', () => {
			it('defaults to undefined', () => {
				const connection = LDAP.createConnection({});

				expect(connection.certFile).toEqual(undefined);
			});
		});

		describe('.sizeLimit', () => {
			it('is a Number', () => {
				const connection = LDAP.createConnection({});

				expect(connection.sizeLimit).toEqual(jasmine.any(Number));
			});
		});

		describe('.timeLimit', () => {
			// eslint-disable-next-line jasmine/no-spec-dupes
			it('is a Number', () => {
				const connection = LDAP.createConnection({});

				expect(connection.timeLimit).toEqual(jasmine.any(Number));
			});
		});

		describe('#connect()', () => {
			it('works with known server', finish => {
				const connection = LDAP.createConnection({
					timeLimit: 5
				});
				connection.connect({
					uri: 'ldap://ldap.forumsys.com:389'
				}, e => {
					expect(e.method).toBe('connect');
					expect(e.result).toBeUndefined();

					connection.disconnect();

					finish();
				}, e => {
					expect(false).toBeTrue();
					finish(new Error('expected to receive success callback, not error'));
				});
			});

			it('fails with bad URI', finish => {
				const connection = LDAP.createConnection({
					timeLimit: 5
				});
				connection.connect({
					uri: '1.1.1.1'
				}, () => {
					expect(false).toBeTrue();
					finish(new Error('expected to receive error callback, not success'));
				}, e => {
					expect(e.method).toBe('connect');
					expect(e.error).toEqual(-1);
					expect(e.message).toEqual(jasmine.any(String));
					finish();
				});
			});
		});

		// TODO: test connecting, binding, searching!

		it('typical connect, bind, search', finish => {
			const connection = LDAP.createConnection({
				timeLimit: 5
			});
			connection.connect({
				uri: 'ldap://ldap.forumsys.com:389'
			}, e => {
				expect(e.method).toBe('connect');
				expect(e.result).toBeUndefined();

				// bind!
				connection.simpleBind({
					dn: 'cn=read-only-admin,dc=example,dc=com',
					password: 'password'
				}, e => {
					// ok we're bound!
					connection.search({
						base: 'ou=mathematicians,dc=example,dc=com',
						scope: LDAP.SCOPE_CHILDREN,
						async: true
						// No idea!
					}, e => {
						// FIXME: We're failing due to network on main thread exception on Android regardless of async flag!
						connection.disconnect();
						finish(); // uhhhh, maybe we should check the results?
					}, e => {
						expect(false).toBeTrue();
						finish(new Error('expected to sucessfully search'));
					});
				}, e => {
					expect(false).toBeTrue();
					finish(new Error('expected to sucessfully bind'));
				});
			}, e => {
				expect(false).toBeTrue();
				finish(new Error('expected to successfully connect'));
			});
		});
	});
});
