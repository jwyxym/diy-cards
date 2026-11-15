--财富王座·辛瑟莱兹
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,6,3)
	--①：超量召唤成功时，把卡名不同的「黄金」速攻魔法作为素材，攻击力上升那个数量×400
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--②：对手发动效果时，取除2个素材，把场上1张卡作为素材
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+10000)
	e2:SetCondition(s.con2)
	e2:SetCost(s.cost2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
--①：可以作为超量素材的「黄金」速攻魔法
function s.matfilter(c)
	return c:IsSetCard(0x571) and c:IsType(TYPE_QUICKPLAY)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_XYZ
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.matfilter),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	if g:GetCount()==0 then return end
	local used={}
	local sg=Group.CreateGroup()
	while true do
		local cand=g:Filter(function(tc) return not used[tc:GetCode()] end,nil)
		if cand:GetCount()==0 then break end
		if sg:GetCount()>0 and not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local tc=cand:Select(tp,1,1,nil):GetFirst()
		if not tc then break end
		used[tc:GetCode()]=true
		sg:AddCard(tc)
	end
	if sg:GetCount()==0 then return end
	Duel.Overlay(c,sg)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(sg:GetCount()*400)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
--②：只有对手发动效果时可以连锁
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) end
	c:RemoveOverlayCard(tp,2,2,REASON_COST)
end
--②：能作为素材的场上卡（这张卡自己以外）
function s.setfilter(c)
	return c:IsSetCard(0x571) and c:IsType(TYPE_QUICKPLAY)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(function(cc)
		return cc~=c and not cc:IsType(TYPE_TOKEN) and not cc:IsImmuneToEffect(e)
	end,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if tc then Duel.Overlay(c,Group.FromCards(tc)) end
	end
	if not c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,nil)
	if sg:GetCount()==0 then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	if sc then
		Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
	end
end
