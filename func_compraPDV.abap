FUNCTION zta03_func_compra.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_ID_CLIENTE) TYPE  ZIDCLI
*"     REFERENCE(I_ITENS) TYPE  ZTA_03_ITENS_T
*"     REFERENCE(I_FORMA_PAGAMENTO) TYPE  ZFORMADEPAG
*"  EXPORTING
*"     REFERENCE(SUBRC) TYPE  SY-SUBRC
*"----------------------------------------------------------------------
  TABLES:zta03_cliente,
         zta03_produto,
         zta03_pedido,
         zta03_ped_pro.

  DATA: lv_valortotal TYPE zvalortotal,
        lv_subtotal   TYPE zvalortotal,
        wa_item       TYPE zta_03_itens_st,
        it_produtos   TYPE TABLE OF zta03_produto,
        it_pedidos    TYPE TABLE OF  zta03_pedido,
        wa_pedidos    TYPE  zta03_pedido.

  IF i_itens[] IS NOT INITIAL.

    SELECT * INTO TABLE it_produtos " Jogando os dados da tabela transparente para a tabela interna"
      FROM zta03_produto
    FOR ALL ENTRIES IN i_itens
      WHERE id_produto = i_itens-id_produto.

    SELECT SINGLE MAX( id_pedido )
        INTO @DATA(lv_id_pedido)
    FROM zta03_pedido.

    SORT it_produtos BY id_produto.
    LOOP AT i_itens INTO wa_item.

      READ TABLE it_produtos ASSIGNING FIELD-SYMBOL(<lfs_produto>) WITH KEY id_produto = wa_item-id_produto BINARY SEARCH.
      IF sy-subrc = 0.

        lv_valortotal = lv_valortotal + ( <lfs_produto>-preco_produto * wa_item-quant_itens ).
        lv_subtotal   = lv_subtotal + ( <lfs_produto>-preco_produto * wa_item-quant_itens ).
      ENDIF.
        zta03_pedido-ID_PEDIDO   = lv_id_pedido + 1.
        zta03_pedido-ID_CLIENTE  = i_ID_CLIENTE.
        zta03_pedido-ID_PRODUTO  = wa_item-ID_PRODUTO.
        zta03_pedido-QUANT_ITENS = wa_item-QUANT_ITENS.
        zta03_pedido-VALOR_TOTAL = lv_valortotal.
        zta03_pedido-DATA        = sy-datum.
        zta03_pedido-HORA        = sy-uzeit.
        INSERT INTO zta03_pedido VALUES zta03_pedido.
        lv_valortotal = 0.
    ENDLOOP.
  ENDIF.
    zta03_ped_pro-id_pedido   = lv_id_pedido.
    zta03_ped_pro-ID_CLIENTE  = i_id_cliente.
    zta03_ped_pro-valor_total = lv_subtotal.
    zta03_ped_pro-forma_pagamento = i_forma_pagamento.
    zta03_ped_pro-data = sy-datum.
    zta03_ped_pro-hora = sy-uzeit.
    INSERT INTO zta03_ped_pro VALUES zta03_ped_pro.

ENDFUNCTION.