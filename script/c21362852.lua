--世界魔神 绝望与坠落的世界
function c21362852.initial_effect(c)
	c:SetUniqueOnField(1,0,21362852)
	--spsummon proc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA) 
	e1:SetCondition(c21362852.espcon)
	e1:SetTarget(c21362852.esptg)
	e1:SetOperation(c21362852.espop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e2)
	--summon success
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(c21362852.sumsuc)
	c:RegisterEffect(e3) 
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,te)
	return te:GetOwner()~=e:GetOwner() end)
	c:RegisterEffect(e1) 
	--skip 
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetCode(EVENT_PHASE+PHASE_END) 
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c21362852.skipcost)
	e2:SetTarget(c21362852.skiptg)
	e2:SetOperation(c21362852.skipop)
	c:RegisterEffect(e2)
	--ov 
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION) 
	e3:SetRange(LOCATION_MZONE) 
	e3:SetCost(c21362852.xovcost)
	e3:SetTarget(c21362852.xovtg) 
	e3:SetOperation(c21362852.xovop)
	c:RegisterEffect(e3) 
	--ov 
	--local e4=Effect.CreateEffect(c)
	--e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	--e4:SetCode(EVENT_CHAIN_SOLVING) 
	--e4:SetRange(LOCATION_MZONE) 
	--e4:SetCountLimit(1) 
	--e4:SetCondition(c21362852.ovcon) 
	--e4:SetOperation(c21362852.ovop)
	--c:RegisterEffect(e4) 
end 
function c21362852.dcfil(c,e,tp) 
	return c:IsCode(21362800) and c:IsReleasable() and Duel.GetLocationCountFromEx(tp,tp,c,e:GetHandler())>0 
end 
function c21362852.rlfil(c) 
	return c:IsCode(21362839,21362843,21362846,21362849) and c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost() 
end 
function c21362852.rlgck(g,e,tp)
	return g:GetCount()==g:GetClassCount(Card.GetCode)
end 
function c21362852.espcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler() 
	local g=Duel.GetMatchingGroup(c21362852.rlfil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	return Duel.IsExistingMatchingCard(c21362852.dcfil,tp,LOCATION_MZONE,0,1,nil,e,tp) and g:CheckSubGroup(c21362852.rlgck,4,4,e,tp)
end
function c21362852.esptg(e,tp,eg,ep,ev,re,r,rp,chk,c)  
	local g=Duel.GetMatchingGroup(c21362852.rlfil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local rg=g:SelectSubGroup(tp,c21362852.rlgck,false,4,4,e,tp) 
	Duel.SendtoDeck(rg,nil,2,REASON_COST) 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local xg=Duel.SelectMatchingCard(tp,c21362852.dcfil,tp,LOCATION_MZONE,0,1,1,nil)  
	if xg:GetCount()>0 then 
		xg:KeepAlive()
		e:SetLabelObject(xg)
		return true
	else return false end
end
function c21362852.espop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_SPSUMMON)  
end
function c21362852.sumsuc(e,tp,eg,ep,ev,re,r,rp)  
	Duel.SetChainLimitTillChainEnd(c21362852.chlimit) 
end
function c21362852.chlimit(e,ep,tp)
	return tp==ep
end
function c21362852.skipcost(e,tp,eg,ep,ev,re,r,rp,chk) 
	local x=e:GetHandler():GetOverlayCount()
	if chk==0 then return x>0 and e:GetHandler():CheckRemoveOverlayCard(tp,x,REASON_COST) end 
	Duel.RemoveOverlayCard(tp,x,x,REASON_COST)
end
function c21362852.skiptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_TURN) end
end
function c21362852.skipop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_TURN)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
end
function c21362852.ovctfil(c) 
	return c:IsCode(21362836) and c:IsDiscardable() 
end 
function c21362852.xovcost(e,tp,eg,ep,ev,re,r,rp,chk)  
	if chk==0 then return Duel.IsExistingMatchingCard(c21362852.ovctfil,tp,LOCATION_HAND,0,1,nil) end 
	local g=Duel.SelectMatchingCard(tp,c21362852.ovctfil,tp,LOCATION_HAND,0,1,1,nil) 
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end 
function c21362852.xovfil(c) 
	return c:IsCanOverlay() and (c:IsFaceup() or c:IsLocation(LOCATION_ONFIELD+LOCATION_REMOVED)) 
end 
function c21362852.xovtg(e,tp,eg,ep,ev,re,r,rp,chk)  
	local g=Duel.GetMatchingGroup(c21362852.ovfil,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,e:GetHandler())
	if chk==0 then return g:GetCount()>0 end 
end 
function c21362852.xovop(e,tp,eg,ep,ev,re,r,rp)  
	local c=e:GetHandler() 
	local g=Duel.GetMatchingGroup(c21362852.ovfil,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,e:GetHandler()) 
	if g:GetCount()>0 then 
		Duel.Overlay(c,g)
	end 
end 



function c21362852.ovfil(c) 
	return c:IsCanOverlay() and (c:IsFaceup() or c:IsLocation(LOCATION_ONFIELD)) 
end 
function c21362852.ovcon(e,tp,eg,ep,ev,re,r,rp)  
	local g=Duel.GetMatchingGroup(c21362852.ovfil,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,e:GetHandler())
	return g:GetCount()>0 
end 
function c21362852.ovop(e,tp,eg,ep,ev,re,r,rp)  
	local c=e:GetHandler() 
	local g=Duel.GetMatchingGroup(c21362852.ovfil,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,e:GetHandler())
	Duel.Hint(HINT_CARD,0,21362852)
	if g:GetCount()>0 then 
		Duel.Overlay(c,g)
	end 
end 

