# Volume Demo Notes

Use this directory as a bind-mount target in class.

Suggested command:

```bash
docker run --rm -it -v ${PWD}/class-demo/volume-demo:/data alpine sh
```

Inside container:

```sh
echo "hello from container" > /data/demo.txt
cat /data/demo.txt
```

Exit container and show `demo.txt` on host to explain persistence and host-container sharing.
