-- 太古剑尊 银河骑士
-- ID: 26052061
-- 字段：新星同盟 0x902
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- 融合素材：卡面未给出，根据系列规律推测为「新星同盟」怪兽 + 光属性怪兽。若不对请自行修改。
    aux.AddFusionProcMix(c,true,true,s.fusfilter1,1,1,s.fusfilter2,1,1)

    -- 规则上当作「新星同盟」卡使用
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetValue(0x902)
    c:RegisterEffect(e0)

    -- ① 特招成功时：双方除外最多2张回卡组
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    -- ② 因对方从场上离开时：双方除外最多2张回卡组
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.lvcon)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
end

function s.fusfilter1(c) return c:IsSetCard(0x902) end
function s.fusfilter2(c) return c:IsAttribute(ATTRIBUTE_LIGHT) end

function s.tgfilter(c) return c:IsLocation(LOCATION_REMOVED) and c:IsAbleToDeck() end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.tgfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:GetReasonPlayer()==1-tp
end