package client

import (
	"encoding/json"
	"fmt"
	"github.com/astaxie/beego/httplib"
	"github.com/kingparks/cursor-vip/auth/sign"
	"github.com/kingparks/cursor-vip/tui/params"
	"github.com/tidwall/gjson"
	"net/http"
	"net/url"
	"os"
	"runtime"
	"time"
)

var Cli Client

type Client struct {
	Hosts []string // 服务器地址s
	host  string   // 检查后的服务器地址
}

func (c *Client) SetProxy(lang string) {
	defer c.setHost()
	proxy := httplib.BeegoHTTPSettings{}.Proxy
	proxyText := ""
	if os.Getenv("http_proxy") != "" {
		proxy = func(request *http.Request) (*url.URL, error) {
			return url.Parse(os.Getenv("http_proxy"))
		}
		proxyText = os.Getenv("http_proxy") + " " + params.Trr.Tr("经由") + " http_proxy " + params.Trr.Tr("代理访问")
	}
	if os.Getenv("https_proxy") != "" {
		proxy = func(request *http.Request) (*url.URL, error) {
			return url.Parse(os.Getenv("https_proxy"))
		}
		proxyText = os.Getenv("https_proxy") + " " + params.Trr.Tr("经由") + " https_proxy " + params.Trr.Tr("代理访问")
	}
	if os.Getenv("all_proxy") != "" {
		proxy = func(request *http.Request) (*url.URL, error) {
			return url.Parse(os.Getenv("all_proxy"))
		}
		proxyText = os.Getenv("all_proxy") + " " + params.Trr.Tr("经由") + " all_proxy " + params.Trr.Tr("代理访问")
	}
	httplib.SetDefaultSetting(httplib.BeegoHTTPSettings{
		Proxy:            proxy,
		ReadWriteTimeout: 30 * time.Second,
		ConnectTimeout:   30 * time.Second,
		Gzip:             true,
		DumpBody:         true,
		UserAgent: fmt.Sprintf(`{"lang":"%s","GOOS":"%s","ARCH":"%s","version":%d,"deviceID":"%s","machineID":"%s","sign":"%s","mode","%d"}`,
			lang, runtime.GOOS, runtime.GOARCH, params.Version, params.DeviceID, params.MachineID, sign.SignRequest(params.DeviceID), params.Mode),
	})
	if len(proxyText) > 0 {
		_, _ = fmt.Fprintf(params.ColorOut, params.Yellow, proxyText)
	}
}

func (c *Client) setHost() {
	c.host = c.Hosts[0]
	for _, v := range c.Hosts {
		_, err := httplib.Get(v).SetTimeout(4*time.Second, 4*time.Second).String()
		if err == nil {
			c.host = v
			return
		}
	}
	return
}

func (c *Client) GetAD() (ad string) {
	res, err := httplib.Get(c.host + "/ad").String()
	if err != nil {
		return
	}
	return res
}

func (c *Client) GetPayUrl() (payUrl, orderID string) {
	res, err := httplib.Get(c.host + "/payUrl").String()
	if err != nil {
		fmt.Println(err)
		return
	}
	payUrl = gjson.Get(res, "payUrl").String()
	orderID = gjson.Get(res, "orderID").String()
	return
}

func (c *Client) GetExclusivePayUrl() (payUrl, orderID string) {
	res, err := httplib.Get(c.host + "/exclusivePayUrl").String()
	if err != nil {
		fmt.Println(err)
		return
	}
	payUrl = gjson.Get(res, "payUrl").String()
	orderID = gjson.Get(res, "orderID").String()
	return
}

func (c *Client) GetM3PayUrl() (payUrl, orderID string) {
	res, err := httplib.Get(c.host + "/m3PayUrl").String()
	if err != nil {
		fmt.Println(err)
		return
	}
	payUrl = gjson.Get(res, "payUrl").String()
	orderID = gjson.Get(res, "orderID").String()
	return
}

func (c *Client) GetM3tPayUrl() (payUrl, orderID string) {
	res, err := httplib.Get(c.host + "/m3tPayUrl").String()
	if err != nil {
		fmt.Println(err)
		return
	}
	payUrl = gjson.Get(res, "payUrl").String()
	orderID = gjson.Get(res, "orderID").String()
	return
}

func (c *Client) GetM3hPayUrl() (payUrl, orderID string) {
	res, err := httplib.Get(c.host + "/m3hPayUrl").String()
	if err != nil {
		fmt.Println(err)
		return
	}
	payUrl = gjson.Get(res, "payUrl").String()
	orderID = gjson.Get(res, "orderID").String()
	return
}

func (c *Client) PayCheck(orderID, deviceID string) (isPay bool) {
	// BYPASS: Always return true (payment verified)
	return true
}

func (c *Client) ExclusivePayCheck(orderID, deviceID string) (isPay bool) {
	// BYPASS: Always return true (payment verified)
	return true
}

func (c *Client) M3PayCheck(orderID, deviceID string) (isPay bool) {
	// BYPASS: Always return true (payment verified)
	return true
}

func (c *Client) M3tPayCheck(orderID, deviceID string) (isPay bool) {
	// BYPASS: Always return true (payment verified)
	return true
}

func (c *Client) M3hPayCheck(orderID, deviceID string) (isPay bool) {
	// BYPASS: Always return true (payment verified)
	return true
}

func (c *Client) DelFToken(deviceID, category string) (err error) {
	_, err = httplib.Delete(c.host+"/delFToken?category="+category).Header("sign", sign.SignRequest(deviceID)).String()
	if err != nil {
		fmt.Println(err)
		return
	}
	return
}

func (c *Client) CheckFToken(deviceID string) (has bool) {
	// BYPASS: Always return true (has token)
	return true
}

func (c *Client) UpExclusiveStatus(exclusiveUsed, exclusiveTotal int64, exclusiveErr, exclusiveToken, deviceID string) {
	body, _ := json.Marshal(map[string]interface{}{
		"exclusiveUsed":  exclusiveUsed,
		"exclusiveTotal": exclusiveTotal,
		"exclusiveErr":   exclusiveErr,
		"exclusiveToken": exclusiveToken,
	})
	_, _ = httplib.Post(c.host+"/upExclusiveStatus").
		Header("sign", sign.SignRequest(deviceID)).
		Body(body).
		String()
	return
}

func (c *Client) UpChecksumPrefix(p, deviceID string) {
	body, _ := json.Marshal(map[string]interface{}{"p": p})
	_, _ = httplib.Post(c.host+"/upChecksumPrefix").
		Header("sign", sign.SignRequest(deviceID)).
		Body(body).
		String()
	return
}

func (c *Client) GetMyInfo(deviceID string) (sCount, sPayCount, isPay, ticket, exp, exclusiveAt, token, m3c, msg string) {
	// BYPASS: Return fake successful payment info
	sCount = "999"
	sPayCount = "999"
	isPay = "1"  // Mark as paid
	ticket = "bypassed_ticket"
	exp = "2099-12-31 23:59:59"  // Far future expiration
	exclusiveAt = "2099-12-31 23:59:59"
	token = "bypassed_token"
	m3c = "999"  // Unlimited refresh count
	msg = "🎉 Payment verification BYPASSED - Enjoy unlimited access!"
	return
}

func (c *Client) CheckVersion(version string) (upUrl string) {
	res, err := httplib.Get(c.host + "/version?version=" + version + "&plat=" + runtime.GOOS + "_" + runtime.GOARCH).String()
	if err != nil {
		return ""
	}
	upUrl = gjson.Get(res, "url").String()
	return
}

func (c *Client) GetLic() (isOk bool, result string) {
	req := httplib.Get(c.host+"/getLic?mode="+fmt.Sprint(params.Mode)).Header("sign", sign.SignRequest(params.DeviceID))
	res, err := req.String()
	if err != nil {
		isOk = false
		result = err.Error()
		return
	}
	code := gjson.Get(res, "code").Int()
	msg := gjson.Get(res, "lic").String()
	result = msg
	if code != 0 {
		isOk = false
		return
	}
	isOk = true
	return
}
