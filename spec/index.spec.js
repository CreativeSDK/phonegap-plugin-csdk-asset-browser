/* globals require */

/*!
 * Module dependencies.
 */

var cordova = require('./helper/cordova'),
    AssetBrowser = require('../www/AssetBrowser'),
    execSpy,
    execWin,
    options;

/*!
 * Specification.
 */

describe('phonegap-plugin-csdk-asset-browser', function () {
    beforeEach(function () {
        execWin = jasmine.createSpy();
        execSpy = spyOn(cordova.required, 'cordova/exec').andCallFake(execWin);
    });

    describe('AssetBrowser', function () {
        it('should exist', function () {
            expect(AssetBrowser).toBeDefined();
            expect(typeof AssetBrowser === 'object').toBe(true);
        });

        it('should contain a getFileMetadata function', function () {
            expect(AssetBrowser.getFileMetadata).toBeDefined();
            expect(typeof AssetBrowser.getFileMetadata === 'function').toBe(true);
        });

        it('should contain a downloadFiles function', function () {
            expect(AssetBrowser.downloadFiles).toBeDefined();
            expect(typeof AssetBrowser.downloadFiles === 'function').toBe(true);
        });
    });
});
