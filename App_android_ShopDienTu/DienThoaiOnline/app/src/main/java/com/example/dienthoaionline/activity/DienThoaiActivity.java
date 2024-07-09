package com.example.dienthoaionline.activity;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.ListView;
import androidx.appcompat.widget.Toolbar;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.example.dienthoaionline.R;
import com.example.dienthoaionline.adapter.DienThoai_Adapter;
import com.example.dienthoaionline.model.Sanpham;
import com.example.dienthoaionline.ultil.checkConnectInternet;
import com.example.dienthoaionline.ultil.server;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class DienThoaiActivity extends AppCompatActivity {

    Toolbar toolbar_Dienthoai;
    ListView lv_Dienthoai;
    DienThoai_Adapter dienThoai_Adapter;
    ArrayList<Sanpham> arr_dienThoai;
    int page = 1;
    
    int id_dienThoai = 0 ;
    //---------------
    View footerview;  // là cái progressBar xoay khi tải thêm sp

    boolean isLoading = false;

    boolean limitData = false;
    mHandler m_Handler;
    //---------------------------------------------------------------------------------

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dien_thoai);

        AnhXa();

        if(checkConnectInternet.haveNetworkConnection(getApplicationContext())){
            // hàm lấy id loại sp truyền từ MainActivity qua
            GetId_loaiSP();

            // thiết lập cho ACTION_BAR
            ActionToolBar();

            //
            GetData(page);
            
            // 
            LoadMoreData();
        }
        else{
            checkConnectInternet.showToast_Short(getApplicationContext(), "Kiểm tra lại Internet");
            finish();
        }

    }

    // gắn giỏ hàng vào toolbar
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu, menu);
        return super.onCreateOptionsMenu(menu);
    }

    // bắt sk khi ấn vào nút giỏ hàng
    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if(item.getItemId() == R.id.menu_gioHang){ //  NẾU BẤM VÀO GIỎ HÀNG -- > CHUYỂN QUA MÀN HÌNH GIỎ HÀNG
            Intent intent = new Intent(getApplicationContext(), GioHangActivity.class);
            startActivity(intent);
        }

        return super.onOptionsItemSelected(item);
    }
    private void LoadMoreData() {

        // sk khi bấm vào 1 item trong listview
        lv_Dienthoai.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Intent intent = new Intent(getApplicationContext(), ChiTietSanPham.class);
                intent.putExtra("thongTin_sanPham", arr_dienThoai.get(position)); // truyền all data của đối tượng

                startActivity(intent);
            }
        });

        lv_Dienthoai.setOnScrollListener(new AbsListView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(AbsListView view, int scrollState) {

            }

            @Override
            public void onScroll(AbsListView view, int firstItem, int visibleItemCount, int totalItemCount) {
                // limitData == false --> chưa hết dữ liêu
                // isLoading == true --> khi progressBar đang load thì ko cho kéo (scroll)   --> false: cho kéo
                if( firstItem + visibleItemCount == totalItemCount  && isLoading == false  && limitData == false  /*&& totalItemCount != 0 */){
                    isLoading = true;
                    ThreadData threadData = new ThreadData();
                    threadData.start();

                }
            }
        });
    }

    private void GetData(int Page) {
        RequestQueue requestQueue = Volley.newRequestQueue(getApplicationContext());
        String url = server.url_DienThoai + String.valueOf(Page) + "";

        Log.e("url "  , url);
        StringRequest stringRequest = new StringRequest(Request.Method.POST, url, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                int id = 0;
                String tenDT = "";
                int giaDT = 0;
                String hinhAnh_DT = "";
                String mota = "";
                int Id_spDienThoai = 0;

                // nếu biến response != null thì mới đọc data
                //  response.length() != 2 : khi hết data thì response trả về 2 cặp ngoặc vuông tương ứng size = 2
                if(response != null  &&    response.length() != 2){// response.length() > 0 ){

                    lv_Dienthoai.removeFooterView(footerview);

                    try {

                        JSONArray jsonArray = new JSONArray(response);

                        for(int i = 0 ; i< jsonArray.length(); i++){
                            JSONObject jsonObject = jsonArray.getJSONObject(i);
                            id = jsonObject.getInt("id");
                            tenDT = jsonObject.getString("tensp");
                            giaDT = jsonObject.getInt("giasanpham");
                            hinhAnh_DT = jsonObject.getString("hinhanhsanpham");
                            mota = jsonObject.getString("motasp");
                            Id_spDienThoai = jsonObject.getInt("idsanpham");

                            arr_dienThoai.add(new Sanpham(id,tenDT, giaDT, hinhAnh_DT, mota, Id_spDienThoai));

                            //cập nhật Adapter khi load datta song
                            dienThoai_Adapter.notifyDataSetChanged();

                        }
                    } catch (JSONException e) {
                        throw new RuntimeException(e);
                    }

                }
                else{ // khi đã hết datta để tải
                        limitData = true;
                        lv_Dienthoai.removeFooterView(footerview);
                        checkConnectInternet.showToast_Short(getApplicationContext(), "Đã hết sản phẩm" );
                }
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Log.e("..................", "hmmmmmmmmmmmmmm");
            }
        })
        {
            // đẩy phương thức POST lên server
            @Nullable
            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                HashMap<String, String> param = new HashMap<>();
                param.put("idsanpham",  String.valueOf(id_dienThoai));
                Log.e("param "  , String.valueOf(param));
                return param;
            }
        };

        requestQueue.add(stringRequest);
    }

    private void ActionToolBar() {
        setSupportActionBar(toolbar_Dienthoai);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true); // HIỂN THỊ NÚT HOME
        toolbar_Dienthoai.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }

    private void GetId_loaiSP() {
        id_dienThoai = getIntent().getIntExtra("id_loaisp", -1);
        Log.e("Gia_Tri_Loai_San_Pham: " , String.valueOf(id_dienThoai));
    }

    private void AnhXa() {
        toolbar_Dienthoai = (Toolbar) findViewById(R.id.toolbar_dienthoai);
        lv_Dienthoai = (ListView) findViewById(R.id.listview_dienthoai);
        arr_dienThoai  = new ArrayList<>();
        dienThoai_Adapter = new DienThoai_Adapter(getApplicationContext(), arr_dienThoai);
        lv_Dienthoai.setAdapter(dienThoai_Adapter);
        //-----------------------------------
        LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
        footerview = inflater.inflate(R.layout.progressbar, null );
        m_Handler = new mHandler();
    }

    // lớp luồng chủ, cấp phép chạy đa luồng
    public class mHandler extends Handler{
        // func quanr lý thread gửi
        @Override
        public void handleMessage(@NonNull Message msg) {
            switch (msg.what){
                case 0:
                    lv_Dienthoai.addFooterView(footerview);
                    break;
                case 1:
                    GetData(++page);
                    isLoading = false;
                    break;
            }
            super.handleMessage(msg);
        }
    }
    public class ThreadData extends Thread{
        @Override
        public void run(){
            m_Handler.sendEmptyMessage(0);
            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
            // gọi pthuc obtainMessage: pthuc liên kết giữa các Thread và Handler
            Message message = m_Handler.obtainMessage(1);
            m_Handler.sendMessage(message);
            super.run();
        }
    }
}