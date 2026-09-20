--临界王战 芬里尔王
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	aux.AddXyzProcedure(c,nil,9,2,nil,nil,99)
	c:EnableReviveLimit()
	
	--③
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UNRELEASABLE_SUM)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE)
	e0b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	e0b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0b:SetValue(1)
	c:RegisterEffect(e0b)
	
	--①效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.xyzcost)
	e1:SetOperation(s.xyzop)
	c:RegisterEffect(e1)
	
	--②效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.relcon)
	e2:SetTarget(s.reltg)
	e2:SetOperation(s.relop)
	c:RegisterEffect(e2)
end

function s.ovfilter(c,e)
	return c~=e:GetHandler() and c:IsCanOverlay() and not c:IsImmuneToEffect(e)
end

function s.xyzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local ct=c:GetOverlayCount()
	local max=math.min(3,ct)
	local removed=c:RemoveOverlayCard(tp,1,max,REASON_COST)
	e:SetLabel(removed)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if not c:IsRelateToEffect(e) or ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,ct,ct,nil,e)
	if #g>0 then
		Duel.Overlay(c,g)
	end
end

function s.relcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.relfilter,1,nil,tp)
end

function s.relfilter(c,tp)
	return c:GetPreviousControler()==tp
end

function s.reltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ovfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil,e) end
end

function s.relop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.ovfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil,e)
	if #g>0 then
		Duel.Overlay(c,g)
	end
end

return s
