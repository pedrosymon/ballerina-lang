import ballerina/io;
import ballerina/runtime;

function workerReturnTest() returns int{
    worker wx returns int {
	    int x = 50;
	    return x + 1;
    }
    return (wait wx) + 1;
}


public function workerSendToWorker() returns int {
    worker w1 {
      int i = 40;
      i -> w2;
    }

    worker w2 returns int {
      int j = 25;
      j = <- w1;

    io:println(j);
      return j;
    }

    return (wait w2) + 1;
}

function workerSendToDefault() returns int{
    worker w1 {
        int x = 50;
        x -> default;
    }
    int y = <- w1;
    return y + 1;
}

function workerSendFromDefault() returns int{
    worker w1 returns int {
        int y = <- default;
        return y;
    }
    int x = 50;
    x -> w1;

    return (wait w1) + 1;
}

public function receiveWithTrap() returns error|int {
    worker w1 {
      int i = 2;
      if(true) {
           error err = error("err", { message: "err msg" });
           panic err;
      }
      i -> w2;
    }

    worker w2 returns error|int {
      error|int  j = trap <- w1;
      return j;
    }

    return wait w2;
}


public function receiveWithCheck() returns error|int {
    worker w1 returns boolean|error{
      int i = 2;
      if(true){
           error err = error("err", { message: "err msg" });
           return err;
      }
      i -> w2;
      io:println("w1");
      return false;
    }

    worker w2 returns error?{
      int j = check <- w1;
      return;
    }

    return wait w2;
}

public function sendToDefaultWithPanicBeforeSendInWorker() returns int {
    worker w1 {
        int i = 2;
        if(true) {
            error err = error("error: err from panic");
            panic err;
        }
        i -> default;
    }
    wait w1;
    int res = <- w1;
    return res;
}

public function sendToDefaultWithPanicBeforeSendInDefault() returns int {
    worker w1 {
        int i = 2;
        i -> default;
    }
    wait w1;
    if(true) {
        error err = error("error: err from panic");
        panic err;
    }
    int res = <- w1;
    return res;
}

public function sendToDefaultWithPanicAfterSendInWorker() returns int {
    worker w1 {
        int i = 2;
        i -> default;
        if(true) {
            error err = error("error: err from panic");
            panic err;
        }
    }
    wait w1;
    int res = <- w1;
    return res;
}

public function sendToDefaultWithPanicAfterSendInDefault() returns int {
    worker w1 {
        int i = 2;
        i -> default;
    }
    int res = <- w1;
    if(true) {
        error err = error("error: err from panic");
        panic err;
    }
    return res;
}

public function receiveFromDefaultWithPanicAfterSendInDefault() {
    worker w1 {
        int i = 2;
        i = <- default;
    }
    int sq = 16;
    sq -> w1;
    if(true) {
        error err = error("error: err from panic");
        panic err;
    }
}

public function receiveFromDefaultWithPanicBeforeSendInDefault() {
    worker w1 {
        int i = 2;
        i = <- default;
    }
    if(true) {
        error err = error("error: err from panic");
        panic err;
    }
    int sq = 16;
    sq -> w1;
}

public function receiveFromDefaultWithPanicBeforeReceiveInWorker() {
    worker w1 {
        int i = 2;
        if(true) {
            error err = error("error: err from panic");
            panic err;
        }
        i = <- default;
    }
    int sq = 16;
    sq -> w1;
    wait w1;
}

public function receiveFromDefaultWithPanicAfterReceiveInWorker() {
    worker w1 {
        int i = 2;
        i = <- default;
        if(true) {
            error err = error("error: err from panic");
            panic err;
        }
    }
    int sq = 16;
    sq -> w1;
    wait w1;
}

public function receiveWithCheckAndTrap() returns error|int {
    worker w1 {
        int i = 2;
        if(true) {
            error err = error("error: err from panic");
            panic err;
        }
        i -> w2;
    }

    worker w2 returns error|int {
        error|int  j = check trap <- w1;
        return j;
    }

    return wait w2;
}

public function receiveWithCheckForDefault() returns boolean|error {
    worker w1 returns boolean|error {
        int i = 2;
        if(true){
            error err = error("err from panic");
            return err;
        }
        i -> default;
        return false;
    }

    error|int j = check <- w1;
    return wait w1;
}

public function receiveWithTrapForDefault() returns error|int {
    worker w1 returns int {
        int i = 2;
        if(true) {
            error err = error("error: err from panic");
            panic err;
        }
        i -> default;
        return i;
    }

    error|int  j = trap <- w1;
    return wait w1;
}

public function receiveDefaultWithCheckAndTrap() returns error|int {
    worker w1 {
        int i = 2;
        if(true) {
            error err = error("error: err from panic");
            panic err;
        }
        i -> default;
    }

    error|int j = check trap <- w1;
    return j;
}

int rs = 0;
public function sameStrandMultipleInvocation() {

    while rs < 2 {
        rs = rs + 1;
        test(rs + 10);
    }
    runtime:sleep(60);
    return;
}

function test(int c) {
    worker w1 {
        int a = c;
        io:println("w1 begin ", c);
        if (c == 11) {
            io:println("w1 sleep ", c);
            runtime:sleep(20);
        }
        io:println("w1 send data ", c);
        a -> w2;
    }
    worker w2 {
        io:println("w2 begin ", c);
        if (c == 12) {
            io:println("w2 sleep ", c);
            runtime:sleep(20);
        }
        int b = <- w1;
        io:println("w2 end ", c, " - ", b);
    }
}


function workerTestWithLambda() returns int {
    invokeTestFunc(5);
    int a = fa.call();
    return a;
}

(function () returns (int)) fa = function () returns (int) { return 88; };

function invokeTestFunc(int c) {
    worker w1 returns int {
        int a = <- default;
        return a;
    }
    int b = 9;
    b -> w1;
}

// First cancel the future and then wait
public function workerWithFutureTest1() returns int {
    future<int> f1 = start add(5, 5);
    worker w1 {
      int i = 40;
      boolean cancelled = f1.cancel();
    }

    worker w2 returns int {
      // Delay the execution of worker w2
      runtime:sleep(200);
      int i = wait f1;
      return i;
    }

    return wait w2;
}

// First wait on the future and then cancel
public function workerWithFutureTest2() returns int {
    future<int> f1 = start add(6, 6);
    worker w1 {
      int i = 40;
      // Delay the execution of worker w1
      runtime:sleep(200);
      boolean cancelled = f1.cancel();
    }

    worker w2 returns int {
      int i = wait f1;
      return i;
    }
    return wait w2;
}

// Concurrently run cancel in worker w1 and wait in worker w2
public function workerWithFutureTest3() returns int {
    future<int> f1 = start add(10, 8);
    worker w1 {
      int i = 40;
      boolean cancelled = f1.cancel();
    }

    worker w2 returns int {
      // Delay the execution of worker w1
      runtime:sleep(5);
      int i = wait f1;
      return i;
    }
    return wait w2;
}

channel<string> chn = new;

function workerWithFutureTest4() returns string {
    worker w1 {
        string msg = "Hello John";
        workerWithDataChannels();
        msg -> chn, "001";
    }

    boolean cancel_w1 = w1.cancel();
    string result = <- chn, "001";
    return result;
}

function workerWithDataChannels() {
    worker w1 {
        string msg = "Hello John";
        waitFor();
        msg -> chn, "001";
    }

    worker w2 {
       string msg = "Hello Peter";
       waitFor();
       msg -> chn, "002";
    }
    string result_w1 = <- chn, "001";
    string result_w2 = <- chn, "002";
}

function add(int i, int j) returns int {
  waitFor();
  return i + j;
}

function waitFor() {
   int l = 0;
   while (l < 99999) {
    l = l +1;
   }
}