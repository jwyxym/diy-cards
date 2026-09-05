local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	--①效果：取对象起动效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,12263011)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	--②效果保留（墓地起动效果）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,122630111)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end

--对象筛选：自己场上/墓地 水属性 or 水族，允许里侧怪兽
function s.spfilter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsAttribute(ATTRIBUTE_WATER) or c:IsRace(RACE_AQUA))
		and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_GRAVE))
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and s.spfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_WATER)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	--先以模板召唤出来（1星0/0电子界）
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_WATER) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	if Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)==0 then return end

	--召唤后覆盖：继承目标怪兽的等级、属性、攻防，种族固定电子界不再覆盖
	local lv=tc:GetLevel()
	local att=tc:GetAttribute()
	local atk=tc:GetAttack()
	local def=tc:GetDefense()

	--等级
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(lv)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	--属性
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(att)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	--【新增：强制固定为电子界族，不会被目标覆盖】
	local e_race=Effect.CreateEffect(e:GetHandler())
	e_race:SetType(EFFECT_TYPE_SINGLE)
	e_race:SetCode(EFFECT_CHANGE_RACE)
	e_race:SetValue(RACE_CYBERSE)
	e_race:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e_race)
	--攻击力
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SET_ATTACK_FINAL)
	e3:SetValue(atk)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
	--守备力
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e4:SetValue(def)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e4)
end

--②效果工具函数：获取对方卡组等级最高怪兽
function s.get_maxlvmonster(tp)
	local g=Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_MONSTER) end,1-tp,LOCATION_DECK,0,nil)
	if #g==0 then return nil end
	local maxlv=0
	local pick=nil
	for tc in aux.Next(g) do
		if tc:GetLevel()>maxlv then
			maxlv=tc:GetLevel()
			pick=tc
		end
	end
	return pick
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) end
	if chk==0 then
		local opp_mon=s.get_maxlvmonster(tp)
		if not opp_mon then return false end
		return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,3,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local opp_mon=s.get_maxlvmonster(tp)
	if not (tc and opp_mon) then return end
	local c=e:GetHandler()
	local g=Group.CreateGroup()
	if tc:IsRelateToEffect(e) then g:AddCard(tc) end
	g:AddCard(opp_mon)
	g:AddCard(c)
	Duel.Destroy(g,REASON_EFFECT)
	Duel.BreakEffect()
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
