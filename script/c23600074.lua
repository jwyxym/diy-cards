-- 天蚀翼蛾 (ID: 23600074)
local s,id,o=GetID()
local SET_ECLIPSE = 0xd92

function s.initial_effect(c)
	-- 超量召唤手续：昆虫族3星怪兽×2只以上
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_INSECT),3,2,nil,nil,99)

	-- 注册全局召唤·特殊召唤活动计数器（限制本回合不能召唤·特殊召唤昆虫族以外的怪兽）
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
	Duel.AddCustomActivityCounter(id+1,ACTIVITY_SPSUMMON,s.counterfilter)

	-- ①：这张卡超量召唤成功的场合才能发动。
	-- 自己的卡组·墓地·除外状态的1张「天蚀」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id) -- ①效果独立 HOPT
	e1:SetCondition(s.thcon)
	e1:SetCost(s.oathcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- ②：把这张卡解放才能发动。选最多有这张卡持有的超量素材数量的自己的墓地·除外状态的昆虫族·光属性怪兽特殊召唤。
	-- 这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o*100) -- ②效果独立 HOPT（防撞车规范 id+o*100）
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end

-- ==================== 全局自肃计数与誓约 Cost ====================
function s.counterfilter(c)
	return c:IsRace(RACE_INSECT)
end

function s.splimit(e,c,sump,sumtype,sumpos,target_p,se)
	return not c:IsRace(RACE_INSECT)
end

function s.oathcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
			and Duel.GetCustomActivityCount(id+1,tp,ACTIVITY_SPSUMMON)==0
	end
	local c=e:GetHandler()
	-- 基础誓约：这些效果发动的回合，自己不是昆虫族怪兽不能召唤·特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)

	-- 客户端当回合自肃提示
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTargetRange(1,0)
	Duel.RegisterEffect(e3,tp)
end

-- ==================== ① 效果：卡组·墓地·除外检索「天蚀」魔陷 ====================
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

function s.thfilter(c)
	return c:IsSetCard(SET_ECLIPSE) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,loc,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,loc)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,loc,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- ==================== ② 效果：解放自身特召多怪（参考74615388深度重构） ====================
function s.spfilter2(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end

function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return s.oathcost(e,tp,eg,ep,ev,re,r,rp,0)
			and c:IsReleasable()
			and c:GetOverlayCount()>0
	end
	s.oathcost(e,tp,eg,ep,ev,re,r,rp,1)
	-- 核心修复：锁定解放前持有的超量素材数量，并作为 Label 传递
	local ct=c:GetOverlayCount()
	e:SetLabel(ct)
	Duel.Release(c,REASON_COST)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 发动前检查：场上释放该卡后留有空间，且当前墓地/除外至少有1只合法目标
		return Duel.GetMZoneCount(tp,c)>0
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	end
	local loc=LOCATION_GRAVE+LOCATION_REMOVED
	-- 动态登记预估数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end

function s.splimit_extra(e,c,sump,sumtype,sumpos,target_p,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 规避青眼精灵龙单次只能特召1只的限制
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end

	local maxc=e:GetLabel()
	local count=math.min(ft,maxc)

	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if #g>0 and count>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 核心修复：采用 SelectSubGroup 替换普通 Select，彻底解决客户端无法多选/只能选1只的截断Bug
		local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,count)
		if sg and #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end

	-- 这个回合，自己不是超量怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit_extra)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end