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

        it('should contain a uploadFile function', function () {
            expect(CSDKAssetBrowser.uploadFile).toBeDefined();
            expect(typeof CSDKAssetBrowser.uploadFile === 'function').toBe(true);
        });
    });

    describe('Data Source Type', function() {
        it('should contain a getDataSources function', function () {
            expect(CSDKAssetBrowser.getDataSources).toBeDefined();
            expect(typeof CSDKAssetBrowser.getDataSources === 'function').toBe(true);
        });

        it('should contain the DataSourceType constants', function () {
            expect(CSDKAssetBrowser.DataSourceType.COMPOSITIONS).toBe(0);
            expect(CSDKAssetBrowser.DataSourceType.DRAW).toBe(1);
            expect(CSDKAssetBrowser.DataSourceType.FILES).toBe(2);
            expect(CSDKAssetBrowser.DataSourceType.LIBRARY).toBe(3);
            expect(CSDKAssetBrowser.DataSourceType.PHOTOS).toBe(4);
            expect(CSDKAssetBrowser.DataSourceType.PSMIX).toBe(5);
            expect(CSDKAssetBrowser.DataSourceType.SKETCHES).toBe(6);
            expect(CSDKAssetBrowser.DataSourceType.LINE).toBe(7);
            expect(CSDKAssetBrowser.DataSourceType.BRUSH).toBe(8);
        });

        it('empty array should be valid', function() {
            expect(CSDKAssetBrowser.getDataSources([]).length).toBe(0);
        });

        it('should be valid', function() {
            expect(CSDKAssetBrowser.getDataSources([CSDKAssetBrowser.DataSourceType.COMPOSITIONS]).length).toBe(1);
            expect(CSDKAssetBrowser.getDataSources([CSDKAssetBrowser.DataSourceType.COMPOSITIONS, CSDKAssetBrowser.DataSourceType.DRAW]).length).toBe(2);
        });

        it('should remove invalid values', function() {
            expect(CSDKAssetBrowser.getDataSources([-1]).length).toBe(0);
            expect(CSDKAssetBrowser.getDataSources([9]).length).toBe(0);
            expect(CSDKAssetBrowser.getDataSources([CSDKAssetBrowser.DataSourceType.COMPOSITIONS, 42, CSDKAssetBrowser.DataSourceType.DRAW]).length).toBe(2);
        });
    });
});
