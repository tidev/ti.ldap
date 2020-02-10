let LDAP;

// const IOS = (Ti.Platform.osname === 'iphone' || Ti.Platform.osname === 'ipad');
// const ANDROID = (Ti.Platform.osname === 'android');

describe('ti.ldap', function () {

	it('can be required', () => {
		LDAP = require('ti.ldap');

		expect(LDAP).toBeDefined();
	});

	it('.apiName', () => {
		expect(LDAP.apiName).toBe('Ti.LDAP');
	});

	describe('constants', () => {

		it('SUCCESS', () => {
			expect(LDAP.SUCCESS).toEqual(jasmine.any(Number));
		});

		describe('Search Scope', () => {
			it('SCOPE_BASE', () => {
				expect(LDAP.SCOPE_BASE).toEqual(jasmine.any(Number));
			});

			it('SCOPE_ONELEVEL', () => {
				expect(LDAP.SCOPE_ONELEVEL).toEqual(jasmine.any(Number));
			});

			it('SCOPE_SUBTREE', () => {
				expect(LDAP.SCOPE_SUBTREE).toEqual(jasmine.any(Number));
			});

			it('SCOPE_CHILDREN', () => {
				expect(LDAP.SCOPE_CHILDREN).toEqual(jasmine.any(Number));
			});

			it('SCOPE_DEFAULT', () => {
				expect(LDAP.SCOPE_DEFAULT).toEqual(jasmine.any(Number));
			});
		});

		describe('Search Attributes', () => {
			it('ALL_USER_ATTRIBUTES', () => {
				expect(LDAP.ALL_USER_ATTRIBUTES).toEqual('*');
			});

			it('ALL_OPERATIONAL_ATTRIBUTES', () => {
				expect(LDAP.ALL_OPERATIONAL_ATTRIBUTES).toEqual('+');
			});

			it('NO_ATTRS', () => {
				expect(LDAP.NO_ATTRS).toEqual('1.1');
			});
		});
	});

});
