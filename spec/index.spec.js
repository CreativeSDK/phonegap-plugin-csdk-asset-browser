/* globals require */

/*!
 * Module dependencies.
 */

var cordova = require('./helper/cordova'),
    CSDKAssetBrowser = require('../www/AssetBrowser'),
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

    describe('CSDKAssetBrowser', function () {
        it('should exist', function () {
            expect(CSDKAssetBrowser).toBeDefined();
            expect(typeof CSDKAssetBrowser === 'object').toBe(true);
        });

        it('should contain a getFileMetadata function', function () {
            expect(CSDKAssetBrowser.getFileMetadata).toBeDefined();
            expect(typeof CSDKAssetBrowser.getFileMetadata === 'function').toBe(true);
        });

        it('should contain a downloadFiles function', function () {
            expect(CSDKAssetBrowser.downloadFiles).toBeDefined();
            expect(typeof CSDKAssetBrowser.downloadFiles === 'function').toBe(true);
        });
    });
});
