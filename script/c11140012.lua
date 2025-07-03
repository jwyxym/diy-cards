--玫瑰猎人·凝视
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    aux.AddXyzProcedureLevelFree(c,s.xyzfilter,2,99)
    --when atk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.xcon)
	e2:SetTarget(s.xtg)
	e2:SetOperation(s.xop)
	c:RegisterEffect(e2)
    --when chaining
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.xcon1)
	e3:SetTarget(s.xtg)
	e3:SetOperation(s.xop)
	c:RegisterEffect(e3)
	--material
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.mttg)
	e4:SetOperation(s.mtop)
	c:RegisterEffect(e4)
end
function s.xyzfilter(c)
    return (c:IsLevel(6) and c:IsRace(RACE_ILLUSION) and c:IsAttribute(ATTRIBUTE_WIND))
    or (c:IsType(TYPE_XYZ) and c:IsRank(6) and c:IsRace(RACE_ILLUSION))
end
--
function s.xcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler()
end
function s.xcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
--e2 & 3
function s.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
function s.tdfilter(c)
    return c:IsLocation(LOCATION_SZONE)
end
function s.xtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.filter(chkc) and s.matfilter(chkc) and chkc~=c end
    local mat=Duel.GetMatchingGroup(nil,tp,LOCATION_SZONE,0,nil)
    local mc=mat:GetCount()
	if chk==0 then return mc>0 and Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    if mc<2 then
	    Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,mc,nil)
    else
        Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
    end
end
function s.xop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		local num=g:GetCount()
		if num>0 and c:RemoveOverlayCard(tp,2,2,REASON_EFFECT)~=0 then
			Duel.Overlay(c,g)
            Duel.BreakEffect()
            local td=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_SZONE,0,1,1,nil)
            if #td>0 then
                Duel.SendtoDeck(td,nil,REASON_EFFECT)
                Duel.ShuffleDeck(td:GetFirst():GetControler())
            end
		end
        Debug.Message("遵循既定的故事。顺理成章将其捕获。")
	end
end
-- 
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsCanOverlay()
		and (c:IsControlerCanBeChanged() or not c:IsType(TYPE_MONSTER))
end
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.filter(chkc) and chkc~=c end
	if chk==0 then return c:IsType(TYPE_XYZ) and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,2,c)
	g:KeepAlive()
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(RESET_CHAIN)
	e1:SetCountLimit(1)
	e1:SetLabelObject(g)
	e1:SetOperation(s.retop)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end
function s.lfilter(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():DeleteGroup()
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local sg=Duel.GetTargetsRelateToChain():Filter(s.lfilter,c,e)
	if sg:GetCount()>0 and c:IsRelateToEffect(e) then
		for tc in aux.Next(sg) do
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				Duel.SendtoGrave(og,REASON_RULE)
			end
		end
		Duel.Overlay(c,sg)
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(sg:GetCount()*400)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
        Debug.Message("苹果……苹果被藏到哪里去了！？")
	end
end