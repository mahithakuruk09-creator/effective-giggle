from backend.worker.main import main

def test_main(capsys):
    main()
    assert "Worker running" in capsys.readouterr().out
