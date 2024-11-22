--苍辉银河的谜之英雄
local cm,m=GetID()
function c38030018.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,2,99,cm.lcheck)
		local e1=Effect.CreateEffect(c)  
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS) 
	e1:SetCondition(cm.ctcon) 
	e1:SetOperation(cm.ctop)
	c:RegisterEffect(e1)  
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,m)
	e2:SetLabelObject(e1)
	e2:SetCondition(cm.descon)
	e2:SetTarget(cm.destg)
	e2:SetOperation(cm.desop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cm.atcon)
	e3:SetValue(cm.val)
	c:RegisterEffect(e3)
end
function cm.lfilter(c)
	return  c:IsLinkSetCard(0x611) 
end
function cm.lfilter1(c)
	return   c:IsLinkSetCard(0x612)
end
function cm.lcheck(g)
	return g:IsExists(cm.lfilter,1,nil) and g:IsExists(cm.lfilter1,1,nil)
end
function cm.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local mg=e:GetHandler():GetMaterial()
	if mg:GetCount()<1 then return false end   
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and mg:GetCount()>0
end 
function cm.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=e:GetHandler():GetMaterial()
	if mg:GetCount()<1 then return false end
	e:SetLabel(#mg)
end
function cm.descon(e,tp,eg,ep,ev,re,r,rp)
	 return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local n=e:GetLabelObject():GetLabel()
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and n>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,n,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cm.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function cm.atcon(e,tp,eg,ep,ev,re,r,rp)
local ph=Duel.GetCurrentPhase()
	 return ph>PHASE_BATTLE_START and ph<PHASE_BATTLE
end
function cm.val(e,c)
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE+LOCATION_MZONE,0,nil,0x611)*400
end