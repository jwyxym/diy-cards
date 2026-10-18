--DS 东御手洗清司郎
local s,id,o=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DRAW_COUNT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.drcount)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.seltg)
	e2:SetOperation(s.selop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.actcon)
	c:RegisterEffect(e3)
end
function s.drcount(e)
	local tp=e:GetHandlerPlayer()
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ct<=1 then
		return 3-ct
	end
	return 1
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	return ac and ac:IsControler(tp) and ac:IsFaceup() and ac:IsSetCard(0xb74) and ac:IsType(TYPE_XYZ)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsControler(tp)
		and re:GetHandler():IsFaceup() and re:GetHandler():IsSetCard(0xb74) and re:GetHandler():IsType(TYPE_XYZ)
end
function s.getxyz(e,tp,eg,ep,ev,re,r,rp)
	if e:GetCode()==EVENT_ATTACK_ANNOUNCE then
		return Duel.GetAttacker()
	else
		return re:GetHandler()
	end
end
function s.rkfilter(c,e,tp,xyz)
	return c:IsType(TYPE_XYZ) and (c:IsSetCard(0xb74) or c:IsAttribute(ATTRIBUTE_WATER))
		and c:IsRank(xyz:GetRank()+1)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.mtfilter(c)
	return c:IsSetCard(0xb74) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xb74) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.seltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local xyz=s.getxyz(e,tp,eg,ep,ev,re,r,rp)
	if not xyz or not xyz:IsFaceup() or not xyz:IsControler(tp) then return false end
	local b1=xyz:GetRank()>0 and Duel.IsExistingMatchingCard(s.rkfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,xyz)
	local b2=Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_DECK,0,1,nil)
	local b3=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 or b3 end
	e:SetLabelObject(xyz)
	e:SetLabel((b1 and 1 or 0)+(b2 and 2 or 0)+(b3 and 4 or 0))
end
function s.selop(e,tp,eg,ep,ev,re,r,rp)
	local xyz=e:GetLabelObject()
	local b=e:GetLabel()
	if not xyz or not xyz:IsFaceup() or not xyz:IsControler(tp) then return end
	local ops={}
	local opval={}
	if b&1~=0 then table.insert(ops,aux.Stringid(id,1)); table.insert(opval,1) end
	if b&2~=0 then table.insert(ops,aux.Stringid(id,2)); table.insert(opval,2) end
	if b&4~=0 then table.insert(ops,aux.Stringid(id,3)); table.insert(opval,3) end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op+1]
	if sel==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.rkfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,xyz)
		local sc=g:GetFirst()
		if sc then
			local mg=xyz:GetOverlayGroup()
			if mg:GetCount()~=0 then
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(xyz))
			Duel.Overlay(sc,Group.FromCards(xyz))
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	elseif sel==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,s.mtfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.Overlay(xyz,g)
		end
	elseif sel==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
