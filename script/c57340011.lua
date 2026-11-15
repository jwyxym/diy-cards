--空绝的残光
local s,id,o=GetID()
function s.initial_effect(c)
	--发动这张卡
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--①：自己场上只有「篡夺」怪兽时，出示3张手卡给1600伤害，再二选一
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)
	--②：「篡夺的继承者·辛瑟莱兹」效果破坏对方卡的回合，在继承者上重叠「财富王座·辛瑟莱兹」
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+10000)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end
--「篡夺」怪兽
function s.takemon(c)
	return c:IsSetCard(0x570) and c:IsType(TYPE_MONSTER)
end
--「黄金」卡或「篡夺」卡
function s.revfilter(c)
	return c:IsSetCard(0x570) or c:IsSetCard(0x571)
end
--①：自己场上没有「篡夺」怪兽以外的怪兽
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return g:FilterCount(s.takemon,nil)==g:GetCount()
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(s.revfilter,tp,LOCATION_HAND,0,nil)>=3 end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1600)
end
--①：追加1次「篡夺」怪兽的通常召唤
function s.extg(e,c)
	return c:IsSetCard(0x570) and c:IsType(TYPE_MONSTER)
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_HAND,0,nil)
	if g:GetCount()<3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg=g:Select(tp,3,3,nil)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
	Duel.Damage(1-tp,1600,REASON_EFFECT)
	local opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	if opt==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e1:SetTarget(s.extg)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	else
		local dg=Duel.GetMatchingGroup(s.takemon,tp,LOCATION_DECK,0,nil)
		if dg:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tc=dg:Select(tp,1,1,nil):GetFirst()
			if tc then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			end
		end
	end
end
--②：「继承者」效果破坏对方卡的标记
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.jc(c,e,tp)
	return c:IsCode(57340009) and c:IsFaceup()
end
function s.xf(c,e,tp,mc)
	return c:IsCode(57340012) and c:IsType(TYPE_XYZ)
		and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local tc=Duel.GetFirstMatchingCard(s.jc,tp,LOCATION_MZONE,0,nil)
		if not tc then return false end
		return Duel.IsExistingMatchingCard(function(cc) return s.xf(cc,e,tp,tc) end,tp,LOCATION_EXTRA,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstMatchingCard(s.jc,tp,LOCATION_MZONE,0,nil)
	if not tc then return end
	if tc:IsFacedown() or tc:IsImmuneToEffect(e) then return end
	local sc=Duel.GetFirstMatchingCard(function(cc) return s.xf(cc,e,tp,tc) end,tp,LOCATION_EXTRA,0,nil)
	if not sc then return end
	local mg=tc:GetOverlayGroup()
	if mg:GetCount()>0 then Duel.Overlay(sc,mg) end
	sc:SetMaterial(Group.FromCards(tc))
	Duel.Overlay(sc,Group.FromCards(tc))
	Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
	sc:CompleteProcedure()
end
