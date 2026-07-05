local s,id,o=GetID()
function s.initial_effect(c)
    -- ① 回收1星+融合复制效果（各能适用）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)
    -- ② 墓地除外→回收除外融合
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+o)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
end
-- ①
function s.lv1filter(c)
    return c:IsLevel(1) and c:IsAbleToHand()
end
function s.fusfilter(c)
    return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:CheckActivateEffect(true,true,false)~=nil
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.lv1filter,tp,LOCATION_GRAVE,0,1,nil)
        or Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_GRAVE,0,1,nil) end
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
        Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(s.lv1filter,tp,LOCATION_GRAVE,0,nil)
    local g2=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_GRAVE,0,nil)
    local b1=#g1>0
    local b2=#g2>0
    if not b1 and not b2 then return end
    -- 第一轮：弹出选项，选择先执行哪个（即使只有一个也弹窗）
    local op
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif b1 then
        op=Duel.SelectOption(tp,aux.Stringid(id,2))
    else
        Duel.SelectOption(tp,aux.Stringid(id,3))
        op=1
    end
    -- op==0: 先回收1星 / op==1: 先复制融合
    if op==0 then
        s.do_lv1(e,tp,g1)
        -- 第二轮：重新判断融合是否可用
        g2=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_GRAVE,0,nil)
        if #g2>0 and Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0 then
            Duel.BreakEffect()
            s.do_fus(e,tp,g2,eg,ep,ev,re,r,rp)
        end
    else
        s.do_fus(e,tp,g2,eg,ep,ev,re,r,rp)
        -- 第二轮：重新判断回收1星是否可用
        g1=Duel.GetMatchingGroup(s.lv1filter,tp,LOCATION_GRAVE,0,nil)
        if #g1>0 and Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,4))==0 then
            Duel.BreakEffect()
            s.do_lv1(e,tp,g1)
        end
    end
end
function s.do_lv1(e,tp,g)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=g:Select(tp,1,1,nil)
    if Duel.SendtoHand(sg,nil,REASON_EFFECT) then
    Duel.ConfirmCards(1-tp,sg) end
end
function s.do_fus(e,tp,g,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=g:Select(tp,1,1,nil)
    local tc=sg:GetFirst()
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(true,true,true)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
    local fc=e:GetLabelObject()
	if fc and fc:IsRelateToChain() and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and fc:IsLocation(LOCATION_DECK) then
		Duel.ConfirmCards(1-tp,fc)
		local fe=fc:CheckActivateEffect(true,true,true)
		if fe then
			local op=fe:GetOperation()
			if op then
				Duel.BreakEffect()
				op(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end
-- ②
function s.filter2(c)
    return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToHand() and c:IsFaceup()
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter2(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    Duel.SelectTarget(tp,s.filter2,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
