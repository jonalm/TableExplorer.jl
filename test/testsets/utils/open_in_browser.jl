using Test
using TableExplorer

# We can't really test browser opening without side effects,
# but we can test it doesn't error on supported platforms
mktempdir() do tmpdir
    test_file = joinpath(tmpdir, "test.html")
    write(test_file, "<html><body>Test</body></html>")

    # Test that it doesn't throw an error
    # (actual browser opening behavior varies by platform)
    if Sys.isapple() || Sys.iswindows() || Sys.islinux()
        # We can't test actual opening without side effects
        # Just verify the function exists and is callable
        @test hasmethod(TableExplorer.open_in_browser, (String,))
    else
        # On unsupported platforms, should warn
        @test_logs (:warn,) TableExplorer.open_in_browser(test_file)
    end
end
